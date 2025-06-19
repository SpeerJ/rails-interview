require 'rails_helper'

RSpec.describe Api::TodoItemsController, type: :controller do
  routes { Rails.application.routes }

  # Create a todo_list that all tests will operate on or associate with
  let!(:todo_list) { TodoList.create!(name: 'Create a Rails App') }

  describe 'GET #index' do
    context 'when todo items exist for the specified todo list' do

      let!(:todo_item1) { todo_list.todo_items.create(name: 'Run Rails cmd line', description: 'run it') }
      let!(:todo_item2) { todo_list.todo_items.create(name: 'Run Rails', description: 'bin/rails dev') }

      let!(:another_todo_list) { TodoList.create(name: 'Create a todo list endpoint')  }
      let!(:todo_item_from_another_list) { another_todo_list.todo_items.create(name: 'Run Generator', description: 'bin/rails generate TodoList')}

      before { get :index, as: :json, params: { todo_list_id: todo_list.id } }

      it 'returns a 200 OK status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns only todo items belonging to the specified todo list in JSON format' do
        json_response = JSON.parse(response.body)

        # Check if the response contains exactly the items for the correct todo_list
        expect(json_response.map { |item| item['id'] }).to match_array([todo_item1.id, todo_item2.id])
        # Ensure items from other lists are not included
        expect(json_response.map { |item| item['id'] }).not_to include(todo_item_from_another_list.id)

        # Basic check for structure
        expect(json_response.first['name']).to eq(todo_item1.name)
      end
    end

    context 'when no todo items exist for the specified todo list' do
      before { get :index, as: :json, params: { todo_list_id: todo_list.id } }

      it 'returns a 200 OK status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns an empty array in JSON format' do
        json_response = JSON.parse(response.body)
        expect(json_response).to be_empty
      end
    end

    context 'when the todo list does not exist' do
      before { get :index, as: :json, params: { todo_list_id: -1 } } # Use a non-existent ID

      it 'returns a 404 Not Found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Test suite for POST #create
  describe 'POST #create' do
    context 'with valid parameters' do
      # Use FactoryBot's attributes_for to get a hash of valid attributes
      # Removed todo_lists_id from valid_attributes as it's passed via the URL for nested resources
      let(:valid_attributes) { { name: 'Valid name', description: 'Valid description' } }

      it 'creates a new TodoItem' do
        expect {
          post :create, as: :json, params: { todo_list_id: todo_list.id, todo_item: valid_attributes }
        }.to change(TodoItem, :count).by(1)
      end

      it 'returns a 201 Created status' do
        post :create, as: :json, params: { todo_list_id: todo_list.id, todo_item: valid_attributes }
        expect(response).to have_http_status(:created)
      end

      it 'returns the created todo item in JSON format' do
        post :create, as: :json, params: { todo_list_id: todo_list.id, todo_item: valid_attributes }
        json_response = JSON.parse(response.body)
        expect(json_response['name']).to eq(valid_attributes[:name])
        expect(json_response['description']).to eq(valid_attributes[:description])
        expect(json_response['todo_list_id']).to eq(todo_list.id)
      end

      it 'sets the Location header to the URL of the created todo item' do
        post :create, as: :json, params: { todo_list_id: todo_list.id, todo_item: valid_attributes }
        expect(response.headers['Location']).to eq(api_todo_list_todo_item_url(todo_list, TodoItem.last))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: nil, description: 'Valid description' } }

      it 'does not create a new TodoItem' do
        expect {
          post :create, as: :json, params: { todo_list_id: todo_list.id, todo_item: invalid_attributes }
        }.not_to change(TodoItem, :count)
      end

      it 'returns a 422 Unprocessable Entity status' do
        post :create, as: :json, params: { todo_list_id: todo_list.id, todo_item: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the todo list does not exist' do
      let(:valid_attributes) { { name: 'Valid name', description: 'Valid description' } }
      it 'returns a 404 Not Found status' do
        expect {
          post :create, as: :json, params: { todo_list_id: -1, todo_item: valid_attributes }
        }.not_to change(TodoItem, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Test suite for PUT #update
  describe 'PUT #update' do
    let!(:todo_item) { todo_list.todo_items.create(name: 'Test item', description: 'Test description') }

    context 'with valid parameters' do
      let(:new_attributes) { { name: 'Updated Title', description: 'Updated Description', completed_at: Time.current } }

      before { put :update, as: :json, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: new_attributes } }

      it 'updates the requested todo item' do
        todo_item.reload # Reload the object to get the updated attributes from the database
        expect(todo_item.name).to eq('Updated Title')
        expect(todo_item.description).to eq('Updated Description')
        expect(todo_item.completed_at).to be_within(1.second).of(Time.current)
      end

      it 'returns a 200 OK status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated todo item in JSON format' do
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(todo_item.id)
        expect(json_response['name']).to eq('Updated Title')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: nil } }

      before { put :update, as: :json, params: { todo_list_id: todo_list.id, id: todo_item.id, todo_item: invalid_attributes } }

      it 'does not update the todo item' do
        original_name = todo_item.name
        todo_item.reload
        expect(todo_item.name).to eq(original_name)
      end

      it 'returns a 422 Unprocessable Entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the todo item does not exist' do
      let(:new_attributes) { { name: 'Updated Title' } }

      before { put :update, as: :json, params: { todo_list_id: todo_list.id, id: -1, todo_item: new_attributes } }

      it 'returns a 404 Not Found status' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the todo item exists but does not belong to the specified todo list' do
      let!(:another_todo_list) { TodoList.create(name: 'Another List for Update Test') }
      let!(:todo_item_from_another_list) { another_todo_list.todo_items.create(name: 'Item for update from another list', description: 'desc') }
      let(:new_attributes) { { name: 'Updated Title from wrong list' } }

      before { put :update, as: :json, params: { todo_list_id: todo_list.id, id: todo_item_from_another_list.id, todo_item: new_attributes } }

      it 'returns a 404 Not Found status (due to scoping)' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:todo_item) { todo_list.todo_items.create(name: 'Test item', description: 'Test description') }

    it 'destroys the requested todo item' do
      expect {
        delete :destroy, as: :json, params: { todo_list_id: todo_list.id, id: todo_item.id }
      }.to change(TodoItem, :count).by(-1)
    end

    it 'returns a 204 No Content status' do
      delete :destroy, as: :json, params: { todo_list_id: todo_list.id, id: todo_item.id }
      expect(response).to have_http_status(:no_content)
    end

    it 'returns no content in the response body' do
      delete :destroy, as: :json, params: { todo_list_id: todo_list.id, id: todo_item.id }
      expect(response.body).to be_empty
    end

    context 'when the todo item does not exist' do
      it 'returns a 404 Not Found status' do
        expect {
          delete :destroy, as: :json, params: { todo_list_id: todo_list.id, id: -1 }
        }.not_to change(TodoItem, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the todo item exists but does not belong to the specified todo list' do
      let!(:another_todo_list) { TodoList.create(name: 'Another List for Destroy Test') }
      let!(:todo_item_from_another_list) { another_todo_list.todo_items.create(name: 'Item for delete from another list', description: 'desc') }

      it 'returns a 404 Not Found status (due to scoping)' do
        expect {
          delete :destroy, as: :json, params: { todo_list_id: todo_list.id, id: todo_item_from_another_list.id }
        }.not_to change(TodoItem, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
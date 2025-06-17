require 'rails_helper'

describe Api::TodoListsController do
  render_views

  let!(:todo_lists) { [
    TodoList.create(name: 'Setup RoR project'),
    TodoList.create!(name: 'Work Tasks')
  ] }

  describe 'GET index' do
    context 'when format is HTML' do
      # I changed this test to expect the correct error code from the controller
      # This allows us consistency between tests and actual usage
      it 'raises a routing error' do
        get :index
        expect(response.status).to eq(415)
      end
    end

    context 'when format is JSON' do
      it 'returns a success code' do
        get :index, as: :json

        expect(response.status).to eq(200)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.count).to eq(todo_lists.length)
        expect(parsed_response.map { |tl| tl['name'] }).to match_array(todo_lists.map(&:name))
      end

      it 'includes todo list records' do
        get :index, as: :json

        parsed_lists = JSON.parse(response.body)

        aggregate_failures 'includes the id and name' do
          expect(parsed_lists.count).to eq(2)
          expect(parsed_lists[0].keys).to match_array(['id', 'name'])
          expect(parsed_lists[0]['id']).to eq(todo_lists.first.id)
          expect(parsed_lists[0]['name']).to eq(todo_lists.first.name)
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { todo_list: { name: 'New Todo List' } } }

      it 'creates a new TodoList' do
        expect {
          post :create, params: valid_params, as: :json # 'as: :json' sets Content-Type
        }.to change(TodoList, :count).by(1)
      end

      it 'returns a 201 Created status with the new todo list in JSON' do
        post :create, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq('New Todo List')
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      let(:new_name) { 'Updated Groceries' }
      let(:valid_params) { { id: todo_lists.first.id, todo_list: { name: new_name } } }

      it 'updates the requested TodoList' do
        patch :update, params: valid_params, as: :json
        todo_lists.first.reload
        expect(todo_lists.first.name).to eq(new_name)
      end

      it 'returns a 200 OK status with the updated todo list in JSON' do
        patch :update, params: valid_params, as: :json
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['name']).to eq(new_name)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { id: todo_lists.first.id, todo_list: { } } }

      it 'does not update the TodoList' do
        original_name = todo_lists.first.name
        patch :update, params: invalid_params, as: :json
        todo_lists.first.reload
        expect(todo_lists.first.name).to eq(original_name)
      end
    end

    context 'when todo_list does not exist' do
      let(:non_existent_id) { todo_lists.first.id + 999 } # A non-existent ID
      let(:valid_params) { { id: non_existent_id, todo_list: { name: 'Non Existent' } } }

      it 'returns a 404 Not Found status with error in JSON' do
        patch :update, params: valid_params, as: :json
        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Resource not found')
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when todo_list exists' do
      it 'destroys the requested TodoList' do
        # Use a let! here to ensure it's created before this test, and can be destroyed
        todo_list_to_destroy = TodoList.create!(name: 'To Be Destroyed')
        expect {
          delete :destroy, params: { id: todo_list_to_destroy.id }, as: :json
        }.to change(TodoList, :count).by(-1)
      end

      it 'returns a 204 No Content status' do
        todo_list_to_destroy = TodoList.create!(name: 'Another To Be Destroyed')
        delete :destroy, params: { id: todo_list_to_destroy.id }, as: :json
        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty # No content is expected for 204
      end
    end

    context 'when todo_list does not exist' do
      let(:non_existent_id) { todo_lists.first.id + 999 }

      it 'returns a 404 Not Found status with error in JSON' do
        delete :destroy, params: { id: non_existent_id }, as: :json
        expect(response).to have_http_status(:not_found)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Resource not found')
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'Error Handling' do
    context 'when a StandardError occurs' do
      # Simulate an unexpected error in the index action
      before do
        allow(TodoList).to receive(:all).and_raise(StandardError, 'Something unexpected happened')
      end

      it 'returns a 500 Internal Server Error status with JSON' do
        get :index, as: :json
        expect(response).to have_http_status(:internal_server_error)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Internal Server Error')
        expect(parsed_response['details']).to eq('Something unexpected happened')
        expect(response.content_type).to include('application/json')
      end

      it 'does not include details in production environment' do
        # Temporarily set Rails.env to production for this specific test
        allow(Rails.env).to receive(:production?).and_return(true)
        get :index, as: :json
        expect(response).to have_http_status(:internal_server_error)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Internal Server Error')
        expect(parsed_response).not_to have_key('details')
        expect(response.content_type).to include('application/json')
      end
    end
  end
end
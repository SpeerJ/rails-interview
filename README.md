# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Build

To build the application:

`bin/setup`

## Run the API

To run the TodoApi in your local environment:

`bin/puma`

## Test

To run tests:

`bin/rspec`

Check integration tests at: (https://github.com/crunchloop/interview-tests)

## Contact

- Santiago Doldán (sdoldan@crunchloop.io)

## About Crunchloop

![crunchloop](https://s3.amazonaws.com/crunchloop.io/logo-blue.png)

We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/#contact).

## My Contributions & Design Decisions
### **1. “Complete All Tasks” Button with Smart Toggle Logic**
I introduced a UI button that allows users to quickly mark all tasks in a Todo List as completed or, if all are already completed, toggle them back to incomplete. This feature checks the current state (some completed vs. all completed) and acts accordingly.
- **Partial Completion:** If even one task is incomplete, clicking the button completes them all.
- **Fully Completed:** Clicking the button toggles all tasks back to incomplete, offering an efficient workflow.

### **2. Persistent Completion Timestamps**
When a task is toggled as completed, the actual timestamp is saved to the field. Toggling completion off clears this date. This makes the feature robust for future extensions (e.g., analytics of completion times or activity reports). `completed_at`
### **3. Clean, Modern UI with Tailwind CSS**
While the project’s goal was to showcase Rails and Turbo expertise, I added a minimal, clean UI using TailwindCSS. This not only improves user experience but shows that I care about front-end polish without sacrificing rapid Rails development.
### **4. Real-Time Interactions with Turbo**
Turbo Frames and Turbo Streams are leveraged throughout, so actions like toggling or creating tasks update only relevant portions of the page. This keeps the UX instantaneous without needing any full-page reloads—demonstrating full-stack Rails proficiency and “modern Rails” conventions.
### **5. Pragmatic Testing: System Over Unit, with Controller & View Coverage**
I noted the project’s size and logic. Because there’s limited business logic and most code is straightforward CRUD, the traditional “unit-heavy” testing pyramid wasn’t suitable:
- **System Tests:** I focused on end-to-end (system) tests. This lays the foundation for any test suite. If you want to expand into unit tests you need certainty that the required refactoring has not damaged the app. These provide a great deal of security in turbo-frame heavy apps, which can be prone to breakage over frame name changes.
- **Controller Specs:** I wrote controller specs to maintain consistency with the existing suite and added view specs to assert the correct rendering of resources.
- **View Specs:** I wrote a small amount of view specs, these tests have a limited value but do prove the basic functionality of resources not covered by system tests.

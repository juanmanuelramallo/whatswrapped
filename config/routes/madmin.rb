# Below are the routes for madmin
namespace :madmin do
  resources :reports
  resources :queries
  resources :query_executions
  root to: "dashboard#show"
end

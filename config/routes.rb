Rails.application.routes.draw do
  mount Blazer::Engine, at: "blazer"
  draw :madmin
  resources :reports, param: :uuid

  root "reports#new"
end

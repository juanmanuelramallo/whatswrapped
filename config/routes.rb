Rails.application.routes.draw do
  draw :madmin
  resources :reports, param: :uuid

  root "reports#new"
end

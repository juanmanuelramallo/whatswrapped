Rails.application.routes.draw do
  draw :madmin
  resources :reports

  root "reports#new"
end

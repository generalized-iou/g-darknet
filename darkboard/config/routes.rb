Rails.application.routes.draw do
  scope '/api' do
    resources :experiments
  end
end

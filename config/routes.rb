Rails.application.routes.draw do
  get 'bills/current', to: 'bills#current', as: 'current_bill'
  get 'bills/old', to: 'bills#old', as: 'old_bills'
  post 'bills/add_jobs_to_bill', to: 'bills#add_jobs_to_bill', as: 'add_jobs_to_bill'
  post 'bills/delete_current', to: 'bills#delete_current', as: 'delete_current_bill'
  post 'bills/pay/:id', to: 'bills#pay', as: 'pay_bill'

  resources :bills
  devise_for :users
  resources :users
  resources :companies

  get 'routes/show_new', to: 'routes#show_new', as: 'new_routes'
  resources :routes

  resources :drivers

  resources :addresses

  get 'jobs/shuttles', to: 'jobs#shuttles', as: 'shuttles'
  resources :jobs
  get 'jobs_ajax/show_all', to: 'jobs#show_all'
  get 'jobs_ajax/show_regular_jobs', to: 'jobs#show_regular_jobs'
  get 'jobs_ajax/show_shuttles', to: 'jobs#show_shuttles'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'jobs#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

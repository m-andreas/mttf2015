Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    get 'datatable_i18n', to: 'datatables#datatable_i18n'
  end
  resources :breakpoints

  get 'bills/current', to: 'bills#current', as: 'current_bill'
  get 'bills/old', to: 'bills#old', as: 'old_bills'
  post 'bills/add_jobs', to: 'bills#add_jobs', as: 'add_jobs_to_bill'
  post 'bills/delete_current', to: 'bills#delete_current', as: 'delete_current_bill'
  post 'bills/pay/:id', to: 'bills#pay', as: 'pay_bill'
  get 'bills/sixt_bill/:id', to: 'bills#sixt_bill', as: 'sixt_bill'
  get 'bills/complete_bill/:id', to: 'bills#complete_bill', as: 'complete_bill'
  get 'bills/drivers_bill/:id', to: 'bills#drivers_bill', as: 'drivers_bill'
  resources :bills
  devise_for :users
  get 'users/invitation', to: 'jobs#new'
  resources :users
  resources :companies
  get 'routes/show_new', to: 'routes#show_new', as: 'new_routes'
  resources :routes

  resources :drivers

  resources :addresses

  post 'jobs/add_to_current_bill/:id', to: 'jobs#add_to_current_bill', as: 'add_job_to_current_bill'
  post 'jobs/remove_from_current_bill/:id', to: 'jobs#remove_from_current_bill', as: 'remove_job_from_current_bill'
  get 'jobs/add_co_driver/:id', to: 'jobs#add_co_driver', as: 'job_add_co_driver'
  get 'jobs/remove_co_driver/:id', to: 'jobs#remove_co_driver', as: 'job_remove_co_driver'
  get 'jobs/print_job/:id', to: 'jobs#print_job', as: 'print_job'
  get 'jobs/multible_cars/:job_amount', to: 'jobs#multible_cars', as: 'job_multible_cars'

  resources :jobs
  get 'jobs_ajax/show_all', to: 'jobs#show_all'
  get 'jobs_ajax/show_regular_jobs', to: 'jobs#show_regular_jobs'

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

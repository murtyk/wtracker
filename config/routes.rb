WTracker::Application.routes.draw do

  resources :applicants, except: [:destroy] do
    collection do
      get :analysis
    end
  end
  resources :applicant_reapplies, only: [:new, :create, :index]

  resources :trainee_placements, only: [:new, :create, :index]

  resources :auto_shared_jobs, only: [:edit, :update]

  resources :job_search_profiles, path: '/profiles', only: [:show, :edit, :update, :index] do
    collection do
      get :remind
    end
  end

  resources :accounts, only: [] do
    collection do
      get :trainee_options
      post :update_trainee_options
    end
  end

  resources :grants, only: [:show, :index, :edit, :update] do
    collection do
      get :skill_metrics
      get :reapply_message
    end
  end

  resources :colleges
  resources :programs, except: [:destroy] do
    member do
      get :trainees_by_auto_lead_status
    end
  end

  resources :klasses do
    member do
      get :events
      get :trainees  # for job leads
      get :trainees_with_email # for bulk emails
      get :visits_calendar
    end
  end

  resources :klass_events,        except: [:index, :show]
  resources :klass_interactions,  except: [:index, :show]
  resources :klass_trainees,      except: [:index, :show]

  resources :assessments,         only: [:new, :create, :destroy, :index]

  resources :klass_certificates,  only: [:new, :create]
  resources :klass_navigators,    only: [:new, :create, :destroy]
  resources :klass_instructors,   only: [:new, :create, :destroy]
  resources :klass_titles,        only: [:new, :create, :destroy] do
    member do
      get :job_search_count
    end
  end

  resources :applicant_sources,      only: [:new, :create, :destroy, :index]
  resources :employment_statuses
  resources :funding_sources,        only: [:new, :create, :destroy, :index]
  resources :special_services,       only: [:new, :create, :destroy, :index]
  resources :grant_trainee_statuses, only: [:new, :create, :destroy, :index]
  resources :unemployment_proofs,    only: [:new, :create, :destroy, :index]

  resources :trainee_files,       only: [:new, :show, :create, :destroy]
  resources :trainee_submits,     only: [:new, :create]
  resources :trainee_assessments, only: [:new, :create, :destroy]
  resources :trainee_emails,      except: [:edit, :update]
  resources :trainee_notes,       except: [:index, :show]
  resources :trainee_statuses,    except: [:index, :show]

  resources :job_searches, only: [:new, :show, :create] do
    member do
      get :details
      get :analyze
    end
    collection do
      get :analysis_present
      get :analyze_slice
      get :complete_analysis
      get :google_places_cache_check_and_start
      get :sort_and_filter
      get :valid_state
      get :search_and_filter_in_state
    end
  end

  resources :job_shares, only: [:new, :show, :create, :index] do
    collection do
      get :new_multiple
      get :company_status
      get :send_to_trainee
    end
  end

  resources :shared_job_statuses, path: '/sjs', only: [:show, :update, :index] do
    member do
      get :clicked
      get :enquire
    end
  end

  resources :employers do
    collection do
      get :mapview
      get :analysis
      get :list_for_trainee
      get :search
      get :contacts_search
      get :get_google_company
      get :add_google_company
      get :search_google
      get :send_email
    end
  end

  resources :contacts,          except: [:index, :show]
  resources :employer_files,    only: [:new, :show, :create, :destroy]
  resources :employer_notes,    except: [:index, :show]
  resources :job_openings,      only: [:new, :create]
  resources :employer_sectors,  only: [:new, :create, :destroy]
  resources :employer_sources,  only: [:new, :create, :destroy]

  resources :user_employer_sources,  only: [:new, :create, :destroy]

  resources :emails, except: [:edit, :update] do
    collection do
      get :new_attachment
    end
  end

  resources :trainee_interactions, except: [:index] do
    collection do
      get :traineelist
    end
  end

  resources :import_statuses, only: [:new, :create, :show] do
    member do
      get :status
    end
    collection do
      get :retry
    end
  end

  resource :companies_finder, only: [:new, :create, :show] do
    collection do
      get :status
      post :add_employer
    end
  end

  resources :reports, only: [:new, :create, :show] do
    collection do
      get :process_next
    end
  end

  devise_for :trainees, skip: [:registrations]
  devise_for :admins,   skip: [:registrations]
  devise_for :users,    skip: [:registrations, :sessions]
  as :user do
    get '/login'     => 'devise/sessions#new',     as: :new_user_session
    post '/login'    => 'devise/sessions#create',  as: :user_session
    delete '/logout' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  resources :trainees do
    collection do
      get :mapview
      get :near_by_colleges
      get :docs_for_selection
      get :search_by_skills
      get :portal
      match 'advanced_search' => 'trainees#advanced_search', via: [:get, :post], as: :advanced_search
    end
  end

  resources :users, except: [:destroy] do
    collection do
      get :online
      get :edit_password
      post :update_password
      get :preferences
      post :update_preferences
    end
  end

  namespace :admin do
    resources :accounts do
      member do
        get :stats
      end
    end
    resources :grants,          except: [:destroy, :index]
    resources :users,           only: [:index]
    resources :sectors,         only: [:new, :show, :create, :index]
    resources :account_states,  only: [:new, :create, :destroy]
    resources :import_statuses, only: [:new, :create, :show, :index, :destroy] do
      member do
        get :status
      end
    end
    resources :counties,        only: [:show, :index]
    resources :cities,          only: [:show, :index]
    resources :aws_s3s,         only: [:show, :index] do
      collection do
        get :recycle_bin
        get :empty_recycle_bin
      end
    end
  end

  get 'static_pages/home'

  resources :dashboards, only: [] do
    collection do
      get :startingpage
      get :summary
      post :grantselected
    end
  end

  root to: 'dashboards#startingpage'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

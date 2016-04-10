WTracker::Application.routes.draw do
  resources :applicants, except: [:destroy] do
    collection do
      get :analysis
    end
  end
  resources :applicant_reapplies, only: [:new, :create, :index]

  resources :trainee_placements, only: [:new, :create, :index]

  resources :auto_shared_jobs, only: [:edit, :update, :index]

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
      get :reapply_message
      get :password_message
      get :hot_jobs_notify_message
    end
  end

  resources :colleges
  resources :programs, except: [:destroy]

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
  resources :klass_trainees,      except: [:index, :show] do
    member do
      get :ojt_enrolled
    end
  end

  resources :assessments,         only: [:new, :create, :destroy, :index]

  resources :klass_certificates,  except: [:index, :show]
  resources :klass_navigators,    only: [:new, :create, :destroy]
  resources :klass_instructors,   only: [:new, :create, :destroy]
  resources :klass_titles,        only: [:new, :create, :destroy] do
    member do
      get :job_search_count
    end
  end

  resources :applicant_sources,      only: [:new, :create, :destroy, :index]
  resources :certificate_categories, only: [:new, :create, :destroy, :index]
  resources :employment_statuses
  resources :funding_sources,        only: [:new, :create, :destroy, :index]
  resources :klass_categories,       only: [:new, :create, :destroy, :index]
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
      # get :details
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
    member do
      get :near_by_trainees
      get :address_location
    end
    collection do
      get :mapview
      get :analysis
      get :list_for_trainee
      get :search
      get :contacts_search
      get :get_google_company
      post :add_google_company
    end
  end

  resources :contacts,          except: [:index, :show]
  resources :employer_files,    only: [:new, :show, :create, :destroy]
  resources :employer_notes,    except: [:index, :show]
  resources :job_openings,      only: [:new, :create]
  resources :hot_jobs
  resources :employer_sectors,  only: [:new, :create, :destroy]
  resources :employer_sources,  only: [:new, :create, :destroy]

  resources :user_employer_sources,  only: [:new, :create, :destroy]

  resources :emails, except: [:edit, :update] do
    collection do
      get :new_attachment
    end
  end

  resources :trainee_interactions, except: [:index]

  resources :import_statuses, only: [:new, :create, :show] do
    member do
      get :status
    end
    collection do
      get :retry
    end
  end

  resources :google_companies, only: [:create, :index]

  resource :companies_finder, only: [:new, :create, :show] do
    collection do
      get :status
      post :add_employer
    end
  end

  resources :reports, only: [:new, :create, :show] do
    collection do
      get :process_next
      get :by_email
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
      match 'advanced_search' => 'trainees#advanced_search', via: [:get, :post], as: :advanced_search
    end
    member do
      get :disable
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

  namespace :trainee do
    resources :trainees, only: [:edit, :update, :show] do
      member do
        get :portal
      end
    end
    resources :job_search_profiles, only: [:show, :edit, :update]
    resources :trainee_files, only: [:new, :create, :index]
    resources :trainee_placements, only: [:new, :create, :index]
    resources :auto_shared_jobs, only: [:edit, :update]
  end

  get 'static_pages/home'

  resources :dashboards, only: [:index] do
    collection do
      get :starting_page
      post :grant_selected
    end
  end

  root to: 'dashboards#starting_page'

  # Api definition
  namespace :api, defaults: { format: :json },
                              constraints: { subdomain: 'operoapi' }, path: '/' do
    scope module: :v1,
              constraints: ApiConstraints.new(version: 1, default: true) do
      resources :sessions, only: [:create, :destroy]
      resources :leads_queues, only: [:show, :update]
    end
  end
end

require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  unless Rails.env.development?
    match "/404", :to => "errors#not_found", :via => :all
    match "/500", :to => "errors#internal_server_error", :via => :all
  end

  resources :forms, only: [:show] do
    member do
      get "js", to: "touchpoints#js", as: :js_form
      get "submit", to: "submissions#new", form: true, as: :submit
    end
    resources :submissions, only: [:new, :create]
  end

  resources :touchpoints, only: [:show] do
    member do
      get "js", to: "touchpoints#js", as: :js
      get "submit", to: "submissions#new", form: true, as: :submit
    end
    resources :submissions, only: [:new, :create]
  end

  namespace :api do
    namespace :v0 do
      resources :forms, only: [:index, :show]
    end
    namespace :v1 do
      resources :organizations, only: [:index]
      resources :forms, only: [:index, :show]
      resources :websites, only: [:index]
      resources :service_providers, only: [:index]
      resources :services, only: [:index]
      resources :goals, only: [:index]
      resources :objectives, only: [:index]
    end
  end

  namespace :admin do
    get "/reporting/hisps/hisps", to: "reporting#hisps", as: :hisps
    get "/reporting/hisps/hisp_services", to: "reporting#hisp_services", as: :hisp_services

    get "/reporting/lifespan", to: "reporting#lifespan", as: :lifespan
    get "/reporting/no_submissions", to: "reporting#no_submissions", as: :no_submissions
    get "/submissions/search", to: "submissions#search", as: :search_submissions
    get "/submissions/a11_analysis", to: "submissions#a11_analysis", as: :a11_analysis
    get "/submissions/a11_chart", to: "submissions#a11_chart", as: :a11_chart
    get "/submissions/responses_per_day", to: "submissions#responses_per_day", as: :responses_per_day
    get "/submissions/responses_by_status", to: "submissions#responses_by_status", as: :responses_by_status
    get "/submissions/submissions_table", to: "submissions#submissions_table", as: :submissions_table
    get "/submissions/performance_gov", to: "submissions#performance_gov", as: :performance_gov

    resources :personas

    get "/heartbeat", to: "site#heartbeat", as: :heartbeat
    get "a11", to: "site#a11", as: :a11
    resources :service_providers do |*args|
      collection do
        get "search", to: "service_providers#search"
      end
      member do
        post "add_tag", to: "service_providers#add_tag", as: :add_tag
        post "remove_tag", to: "service_providers#remove_tag", as: :remove_tag
      end
    end
    resources :services do
      collection do
        get "search", to: "services#search"
        get "export_csv", to: "services#export_csv", as: :export_csv
      end
      member do
        get "equity-assessment", to: "services#equity_assessment", as: :equity_assessment
        get "cx-reporting", to: "services#omb_cx_reporting", as: :omb_cx_reporting
        post "add_tag", to: "services#add_tag", as: :add_tag
        post "remove_tag", to: "services#remove_tag", as: :remove_tag

        post "submit", to: "services#submit", as: :submit
        post "approve", to: "services#approve", as: :approve
        post "verify", to: "services#verify", as: :verify
        post "archive", to: "services#archive", as: :archive
        post "reset", to: "services#reset", as: :reset
      end

      resources :service_stages, except: [:index]
    end

    resources :collections do
      member do
        post "copy", to: "collections#copy", as: :copy
        post "submit", to: "collections#submit", as: :submit
        post "publish", to: "collections#publish", as: :publish
        get "events", to: "collections#events", as: :events
      end
    end
    resources :omb_cx_reporting_collections
    resources :goals do
      member do
        patch "update_organization_id", to: "goals#update_organization_id", as: :update_organization_id
        patch "update_name", to: "goals#update_name", as: :update_name
        patch "update_description", to: "goals#update_description", as: :update_description
        patch "update_tags", to: "goals#update_tags", as: :update_tags
        patch "update_users", to: "goals#update_users", as: :update_users
        patch "update_four_year_goal", to: "goals#update_four_year_goal", as: :update_four_year_goal
        patch "update_parent_id", to: "goals#update_parent_id", as: :update_parent_id
        get "targets", to: "goals#goal_targets", as: :targets
        get "goal_objectives", to: "goals#goal_objectives", as: :goal_objectives
      end
      resources :goal_targets
      resources :objectives
    end
    resources :milestones
    resources :objectives

    resources :websites do
      collection do
        get "search", to: "websites#search"
        get "gsa", to: "websites#gsa"
        get "dendrogram", to: "websites#dendrogram", as: :dendrogram
        get "dendrogram_json", to: "websites#dendrogram_json"
        get "export_csv", to: "websites#export_csv", as: :export_csv
        get "collection_preview", to: "websites@collection_preview", as: :collection_preview
      end
      member do
        get "costs", to: "websites#costs", as: :costs
        get "statuscard", to: "websites#statuscard", as: :statuscard
        get "collection_request", to: "websites@collection_request", as: :collection_request
        post "approve", to: "websites#approve", as: :approve
        post "deny", to: "websites#deny", as: :deny
        get "events", to: "websites#events", as: :events
        post "add_tag", to: "websites#add_tag", as: :add_tag
        post "remove_tag", to: "websites#remove_tag", as: :remove_tag
        get "versions", to: "websites#versions", as: :versions
        get "versions_export", to: "websites#export_versions", as: :export_versions
      end
    end
    get :registry, to: "site#registry", as: :registry
    resources :digital_service_accounts
    resources :digital_products

    resources :forms do
      member do
        get "notifications", to: "forms#notifications", as: :notifications
        get "example", to: "forms#example", as: :example
        get "export", to: "forms#export", as: :export
        get "export_pra_document", as: :export_pra_document
        get "export_submissions", to: "forms#export_submissions", as: :export_submissions
        get "export_a11_header", to: "forms#export_a11_header", as: :export_a11_header
        get "export_a11_submissions", to: "forms#export_a11_submissions", as: :export_a11_submissions
        patch "invite", to: "forms#invite", as: :invite
        get "js", to: "forms#js", as: :js
        get "permissions", to: "forms#permissions", as: :permissions
        get "compliance", to: "forms#compliance", as: :compliance
        get "questions", to: "forms#questions", as: :questions
        get "responses", to: "forms#responses", as: :responses
        get "delivery_method", to: "forms#delivery_method", as: :delivery_method
        post "add_user", to: "forms#add_user", as: :add_user
        post "copy", to: "forms#copy", as: :copy
        post "publish", to: "forms#publish", as: :publish
        post "archive", to: "forms#archive", as: :archive
        delete "remove_user", to: "forms#remove_user", as: :remove_user
        patch "update_title", to: "forms#update_title", as: :update_title
        patch "update_instructions", to: "forms#update_instructions", as: :update_instructions
        patch "update_disclaimer_text", to: "forms#update_disclaimer_text", as: :update_disclaimer_text
        patch "update_success_text", to: "forms#update_success_text", as: :update_success_text
        patch "update_ui_truncation", to: "forms#update_ui_truncation", as: :update_ui_truncation
        patch "update_display_logo", to: "forms#update_display_logo", as: :update_display_logo
        patch "update_admin_options", to: "forms#update_admin_options", as: :update_admin_options
        patch "update_form_manager_options", to: "forms#update_form_manager_options", as: :update_form_manager_options
        get "events", to: "forms#events", as: :events
      end
      collection do
        post "copy", to: "forms#copy", as: :copy_id
      end
      resources :form_sections, except: [:index, :show, :edit] do
        patch "sort", to: "form_sections#sort", as: :sort_sections
        patch "update_title", to: "form_sections#update_title", as: :inline_update
      end
      resources :questions do
        member do
          patch "question_options", to: "question_options#sort", as: :sort_question_options
        end
        resources :question_options, except: [:index, :show] do
          patch "update_title", to: "question_options#update_title", as: :inline_update
        end
        collection do
          patch "sort", to: "questions#sort", as: :sort_questions
        end
      end
      resources :submissions, only: [:show, :update, :destroy] do
        member do
          post "flag", to: "submissions#flag", as: :flag
          post "unflag", to: "submissions#unflag", as: :unflag
          post "archive", to: "submissions#archive", as: :archive
          post "unarchive", to: "submissions#unarchive", as: :unarchive
          post "add_tag", to: "submissions#add_tag", as: :add_tag
          post "remove_tag", to: "submissions#remove_tag", as: :remove_tag
        end
      end
    end
    resources :users, except: [:new] do
      collection do
        get "inactive", to: "users#inactive", as: :inactive
        get "deactivate", to: "users#deactivate"
        get "active", to: "users#active", as: :active
      end
    end
    resources :organizations do
      collection do
        get "search", to: "organizations#search"
      end
      member do
        patch "performance_update", to: "organizations#performance_update", as: :performance_update
        get "performance", to: "organizations#performance", as: :performance
        get "performance/edit", to: "performance#edit", as: :performance_edit
        get "performance/apg/:apg", to: "performance#apg", as: :apg
        post "add_tag", to: "organizations#add_tag", as: :add_tag
        post "remove_tag", to: "organizations#remove_tag", as: :remove_tag
        get "create_two_year_goal", to: "organizations#create_two_year_goal", as: :create_two_year_goal
        get "create_four_year_goal", to: "organizations#create_four_year_goal", as: :create_four_year_goal
        delete "delete_two_year_goal", to: "organizations#delete_two_year_goal", as: :delete_two_year_goal
        delete "delete_four_year_goal", to: "organizations#delete_four_year_goal", as: :delete_four_year_goal
      end
    end
    resources :service_stages
    resources :barriers
    resources :service_stage_barriers

    get "dashboard", to: "site#index", as: :dashboard
    get "integrations", to: "site#integrations", as: :integrations
    get "performance", to: "performance#index", as: :performance
    get "performance/apg", to: "performance#apgs", as: :apgs
    get "management", to: "site#management", as: :management
    get "events", to: "site#events", as: :events
    get "events/export", to: "site#events_export", as: :export_events
    root to: "forms#index"
    get "feed", to: "submissions#feed", as: :feed
    get "export_feed", to: "submissions#export_feed", as: :export_feed
  end

  get "registry", to: "site#registry", as: :registry
  get "registry/guidance", to: "site#registry_guidance"
  get "agencies", to: "site#agencies", as: :agencies
  get "profile", to: "profile#show", as: :profile
  patch "profile", to: "profile#update", as: :profile_update
  get "status", to: "site#status", as: :status
  get "index", to: "site#index", as: :index
  root to: redirect(ENV.fetch("INDEX_URL"))
end

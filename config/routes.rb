Rails.application.routes.draw do

  
  namespace :administrator do
  get 'contest_descriptions/new'
  end

  namespace :administrator do
  get 'contest_descriptions/index'
  end

  namespace :administrator do
  get 'contest_descriptions/create'
  end

  namespace :administrator do
    resources :testimonials do
      member do
        get 'delete'
      end
    end
    resource :special
    resources :reports, only: [:new, :create]
    resources :users do
      member do
        get 'delete'
      end
      collection do
        get 'export'
      end
      resource :activation, :only => :create
      resources :attachments, :only => [ :index, :new, :create ] do
        collection do
          post 'order'
        end

      end
    end
    get :change_image_order, to: 'attachments#change_image_order'

    resources :attachments, :except => [ :index, :new, :create ] do
      member do
        get 'delete'
      end
      resources :critiques, :only => [ :new, :create ]
    end

    resources :courses do
      member do
        get 'delete'       
      end     
     
      resources :attachments, :only => [:index, :new,:create]
      resources :forum_topics, :only => [:index, :new,:create]
      resources :lessons, :only => [:index, :new,:create]
      #resources :scheduled_courses, :only => [:index, :new,:create]
      resources :scheduled_courses, only: [:index]
    end
    
    resources :blogs do
      member do
        get 'delete'       
      end     
     
      resources :attachments, :only => [:index, :new,:create]     
    end

    resources :certificate, only: [:index, :generate] do
		collection do
			post 'generate'
		end
    end
    resources :renewals, only: [:index, :create, :destroy]

    resources :workshops do
      member do
        get 'delete'
      end
    end

    resources :packages do
      member do
        get 'delete'
      end
      resources :attachments, :only => [ :index, :new, :create ]
    end

    resources :banner_images, only: [:index, :create, :destroy]
    resources :student_galleries, only: [:index, :create, :destroy]
    resources :contests, only: [:index, :create, :destroy, :new]
    resources :contest_descriptions, only: [:index, :create, :new, :edit]

    resources :settings

    resources :forum_topics do
      member do
        get 'delete'
      end
      resources :posts, :controller => 'forum_posts', :only => [ :new, :create ]
    end

    resources :lessons, :except => [ :index, :new, :create ] do
      member do
        get 'delete'
      end
      resources :attachments,:only => [ :index, :new, :create ] do
        collection do
          post 'order'
        end
      end
      resources :assignments, :only => [ :index, :new, :create ]
    end

    resources :assignments, :except => [ :index, :new, :create ] do
      member do
        get 'delete'
      end
      resources :attachments, :only => [ :index, :new, :create ] do
        collection do
          post 'order'
        end
      end
      resources :rearrangements
    end

    resources :rearrangements, :except => [ :index, :new, :create ] do
      member do
        get 'delete'
      end
      resources :attachments, :only => [ :index, :new, :create ] do
        collection do
          post 'order'
        end
      end
    end

    resources :scheduled_assignments, :only => :show do
      resources :submissions, :controller => 'assignment_submissions', :only => :index
    end

    resources :assignment_submissions, :except => [ :index, :new, :create ] do
      member do
        get 'delete'
      end
      resources :attachments, :only => [ :index, :new, :create ] do
        collection do
          post 'order'
        end
      end
      resources :critiques, :only => [ :new, :create ]
    end

    resources :scheduled_courses, :only => [:show] do
      resources :enrolments, :only => [ :index, :new, :create ]
    end

    resources :critiques, :only => [ :edit, :update, :destroy ] do
      member do
        get 'delete'
      end
    end

    resources :enrolments, :only => [ :edit, :update, :destroy ] do
      member do
        get 'delete'
      end
    end

    resources :forum_posts, :only => [ :edit, :update, :destroy ] do
      member do
        get 'delete'
      end
    end

    resources :exchange_rates, :except => :show do
      member do
        get 'delete'
      end
    end

    resources :partners do
      member do
        get 'delete'
      end
    end

  end

  namespace :instructor do
    resource :account, :controller => 'users', :only => [ :edit, :update ]
    resources :attachments do
      member do
        get 'delete'
      end
    end
    
    resources :lessons_comment, :only => [:delete] do
      member do
        get 'delete'
      end
    end
    resources :lessons, :only => :show
    resources :assignments, :only => :show
    resources :updates, :only => [:index]
    resources :mystudents, :only => [:index] do
      member do
        get 'courses'
      end
    end
    resources :courses, :only => :index do
      resources :scheduled_courses, :only => :index
    end
    resources :scheduled_courses, :only => [:show, :destroy] do
      member do
        get 'delete'
      end
      resources :enrolments, :only => [ :index, :new, :create ]
    end
    resources :forum_topics, :except => :destroy do
      resources :posts, :controller => 'forum_posts', :only => [ :new, :create ]
    end

    resources :submissions, :controller => 'assignments_submissions', :except => [ :new, :create ] do
      resources :attachments, :only => [ :index, :new, :create ] do
        collection do
          post 'order'
        end
      end
      resources :critiques, :controller => 'assignment_critiques', :only => [ :new, :create ]
      #resource :sequence
    end
    resources :forum_posts, :only => [ :edit, :update ]
    get 'sequence/:id', :controller => "assignment_submissions", :action => 'sequence', as: :instructor_sequence 
    
    get 'lessons/:lesson_id/attachments/new',:controller => "upload_video", :action => 'new', :as => 'lession' 
    get 'lessons/:lesson_id/attachments',:controller => "upload_video", :action => 'new',:as => 'lession1'
    post 'lessons/:lesson_id/attachments',:controller => "upload_video", :action => 'create', :as => 'path_video'
#    
    get 'lessons/:lesson_id/upload',:controller => "upload_video", :action => 'upload', :as => 'inst_assignment'
    get 'lessons/:lesson_id',:controller => "upload_video", :action => 'upload', :as => 'inst_assignment1'
    post 'lessons/:lesson_id',:controller => "upload_video", :action => 'upload_video', :as => 'path_video_attach'
  end
  get 'courses/fulldownload', :controller => 'courses', :action => 'fulldownload'
  
   
  namespace :student do
    resource :account, :controller => 'users', :only => [ :edit, :update ]
    resources :attachments do
      member do
        get 'delete'
      end
      collection do
        post 'order'
      end
    end
    
    resources :courses, :controller => 'scheduled_courses' do
      resources :lessons, :controller => 'scheduled_lessons', :only => :show
      resources :reviews, only: [ :new, :create, :destroy ]
    end
    
    resources :assignments, :controller => 'scheduled_assignments' do
      resources :submissions, :controller => 'assignment_submissions', :only => [ :new, :create ]
    end

    resources :submissions, :controller => 'assignment_submissions', :except => [ :new, :create ] do
      resources :attachments, :only => [ :index, :new, :create ] do
        collection do
          post 'order'
          get 'sequence'
        end
      end
      resources :critiques do
        resources :critiques, :only => [ :new, :create ]
      end
    end

    resources :forum_topics, :except => :destroy do
      resources :posts, :controller => 'forum_posts', :only => [ :new, :create ]
    end
    resources :updates, :only => [:index]
    resources :forum_posts, :only => [ :edit, :update ]

    get 'sequence/:id', :controller => "assignment_submissions", :action => 'sequence', as: :student_sequence
    
    get 'lessons/:lesson_id/assignments/:assignments_id/attachments/new',:controller => "upload_video", :action => 'new', :as =>'stdunt_post_video'
    get 'lessons/:lesson_id/assignments/:assignments_id/attachments',:controller => "upload_video", :action => 'new', :as =>'stdunt_post_video1'
    post 'lessons/:lesson_id/assignments/:assignments_id/attachments',:controller => "upload_video", :action => 'create', :as => 'post_video'
  end
  get 'attachments/:id/:style.:format', :controller => 'attachments', :action => 'download', as: :attachment_download
 
  get "paypal" => "purchase_notifications#paypal" ,:path => "purchase_notifications/paypal"
  
  post 'purchase_notifications/:gateway', :controller => 'purchase_notifications', :action => 'create', :requirements => { :gateway => /[a-z_]+/i }, as: :purchase_notifications

  post 'package_purchase_notifications/:gateway', :controller => 'package_purchase_notifications', :action => 'create', :requirements => { :gateway => /[a-z_]+/i }, as: :package_purchase_notifications

  get 'purchase_complete/:gateway', :controller => 'purchase_completions', :action => 'create', :requirements => { :gateway => /[a-z_]+/i }, as: :purchase_completions

  resources :instructors, :only => [ :index, :show ]

  resources :courses, :only => [ :index, :show ] do
    resource :purchase, :only => [ :new, :create ] do
      get 'renew' => 'purchases#renew'
      post 'renew_subscription' => 'purchases#renew_subscription'
    end
  end
  
  put '/courses/:course_id/enrolments/:id/unsubscribe', to: 'purchases#unsubscribe', as: :unsubscribe_course
  get '/courses/:course_id/purchases/:id/execute', to: 'purchases#execute', as: :payment_execute

  get '/courses/:course_id/purchases/:id/renew_execute', to: 'purchases#renew_execute', as: :renew_payment_execute
  # put '/courses/:course_id/purchase/:id/payment', to: 'purchase#payment', as: :payment

  get 'course_select/:id', :controller => 'courses', :action => 'select', as: :select_course

  get 'courses/tags/:tag', :controller => 'courses', :action => 'index', as: :course_tags

  get 'courses/types/:course_type', :controller => 'courses', :action => 'index', as: :course_type
  
  	
  get 'files/courses/:id/:style', :controller => 'courses', :action => 'photo', as: :course_photo
   get 'files/blogs/:id/:style', :controller => 'courses', :action => 'blogphoto', as: :blog_photo
	
	post '/tinymce_assets' => 'tinymce_assets#create'
	
  get 'tags', :controller => 'courses', :action => 'tag_cloud', as: :tags
	get 'blog', :controller => 'blogs', :action => 'index'

  get 'contest/', :controller => 'contests', :action => 'index'


	post 'blogs/savecomment', :controller => 'blogs', :action => 'savecomment'
  get 'blog/:id', :controller => 'blogs', :action => 'show', as: :inner_blog
  resources :packages, :only => [ :index, :show ] do
    resource :purchase, :controller => 'package_purchases', :only => [ :new, :create ]
  end

  get 'files/packages/:id/:style', :controller => 'packages', :action => 'photo', as: :package_photo

  resources :workshops, :only => [ :index, :show ]

  get 'files/workshops/:offset/:id/:style', :controller => 'workshops', :action => 'photo', as: :workshop_photo

  resources :enquiries, :only => [:new, :create] do
    collection  do
      get 'submitted'
    end
  end
	
  resource :session, :only => [:new, :create ]

  get '/sessions/login', to: 'sessions#new', as: :login
  get '/sessions/logout', to: 'sessions#destroy', as: :logout

  # map.with_options :controller => 'sessions', :conditions => { :method => :get } do |session|
  #   session.login 'login', :action => 'new'
  #   session.logout 'logout', :action => 'destroy'
  # end

  resources :simple_signups, :only => [ :create ]

  resource :activation, :only => [ :new, :create ]

  resource :password, :only => [ :new, :create ]

  post 'set_currency', to: 'application#set_currency'
  get 'users/:user_id/activation/:activation_code_confirmation',
                             :controller => 'activations',
                             :action => 'create',
                             :requirements => { :user_id => /\d+/, :activation_code_confirmation => /[a-f\d]+/i }, as: :create_user_activation

  resource :user, :controller => 'usersnew', :only => [:new, :create]
  get "user"=>"usersnew#new"
  get "enquiries"=>"enquiries#new"
  get 'files/users/:id/:style', :controller => 'users', :action => 'photo', as: :user_photo

  get 'files/users/instructors/:id/:style', :controller => 'users', :action => 'instructor_photo', as: :user_instructor_photo

  # with_options :controller => 'pages', :action => 'show', :conditions => { :method => :get } do
  #   %w(administrator instructor student).each do |namespace|
  #     send("#{namespace}_page", "#{namespace}/pages/*names", :role => namespace)
  #     send("#{namespace}_root", "#{namespace}", :names => 'home', :role => namespace)
  #   end
  #   o.page 'pages/*names'
  #   o.root :names => 'home'
  # end

  %w(administrator instructor student).each do |namespace|
    get "#{namespace}/pages/:names", :controller => 'pages', :action => 'show', :role => namespace, as: "#{namespace}_page"
    get "#{namespace}", :controller => 'pages', :action => 'show', :names => 'home', :role => namespace, as: "#{namespace}_root"
  end

  get 'pages/*names', :controller => 'pages', :action => 'show', as: :page

  root :controller => 'pages', :action => 'show', :names => 'home'

  get 'spellings', :controller => "spellings", :action => "check", as: :spellings

  #get 'test', :controller => 'PurchaseNotifications', :action => 'test', as: :test

  resources :student_galleries, only: [:index]

  resources :contests, only: [:index]

  resources :image_order, :only => [:new] do
    collection  do
      post 'change_image_order'
    end
  end
  
  #get '/facebook/connect', to: 'omniauth_callbacks#connect'

  get '/auth/facebook/callback', to: 'omniauth_callbacks#facebook'

  get 'sitemap' => 'sitemaps#index', :as => :sitemap
  
  #get '/blog', to: 'blog#redirect' , :as => :blog 

  get "/instagram/connect" do
    redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
  end

  get "/instagram/callback" do
    response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
    session[:access_token] = response.access_token
    redirect "/nav"
  end
end

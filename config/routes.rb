Rails.application.routes.draw do
  root to: 'pages#show', defaults: {page: 'home'}, as: :home

  get :':page', to: 'pages#show', as: :page, constraints: {
    page: Regexp.new((PagesController::PAGES - ['home']).join('|'))
  }

  get :about, to: 'pages#about'
  get :faq, to: 'pages#faq'
  get :terms, to: 'pages#terms'
  get :privacy, to: 'pages#privacy'

  resources :currencies, only: [:index, :show]
  resources :indexes, only: [:index, :show]

  post :signup, to: 'users#create'
  patch :signup, to: 'users#update'

  get :unsubscribe, to: 'users#unsubscribe', as: :unsubscribe_user

  scope module: :user do
    get :'email/confirm', to: 'email#confirm', as: :confirm_email

    get :'phone/confirmation/resend', to: 'phone#resend_confirmation_code',
                                      as: :resend_phone_confirmation_code

    get :login, to: 'sessions#new'
    post :login, to: 'sessions#create'
    get :logout, to: 'sessions#destroy'

    resource :account, controller: :account, only: :new
    get :account, to: redirect('/account/dashboard')
    namespace :account do
      resource :dashboard, controller: :dashboard, only: :show
    end

    get :portfolio, to: redirect('/portfolio/currencies')
    namespace :portfolio do
      resources :currencies, controller: :currency_holdings, only: :index
      resources :indexes, controller: :tracked_indexes, only: :index
    end

    get :transactions, to: redirect('/transactions/overview')
    namespace :transactions do
      resources :deposits, only: :index
      resources :rebalancings, only: :index
      resources :withdrawals, only: :index
      get :report, to: 'reports#download'
    end
    get :'/transactions/withdrawals/:id/confirm', # FIXME: Can't expose ID!
      to: 'transactions/withdrawals#confirm_by_email',
      as: :confirm_withdrawal_by_email

    get :settings, to: redirect('/settings/account')
    scope :settings do
      resource :account, controller: :account, only: :show
      resource :email, controller: :email, only: :show
      resource :phone, controller: :phone, only: :show
      resource :security, controller: :security, only: :show
    end
  end

  get :admin, to: redirect('/admin/users')
  namespace :admin do
    resources :users, only: :index
    resources :currencies, only: :index
    resources :valuations, only: :index

    mount Sidekiq::Web, at: :jobs
  end

  if Rails.env.development?
    namespace :security do
      resources :violations, only: :create
    end

    mount LetterOpenerWeb::Engine, at: :emails

    get :'sms/:text', to: proc { |request|
      [200, {}, [CGI.unescape(request['PATH_INFO'][5..-1])]]
    }, as: :sms_opener_web
  end
end

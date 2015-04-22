EdxFourth::Application.routes.draw do

  root :to => 'request#index'

  get '/request', :to => 'request#index'
  get '/request/sql', :to => 'request#sql'
  get '/request/arecord', :to => 'request#arecord'
  get '/request/send_csv', :to => 'request#send_csv'

end

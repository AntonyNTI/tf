require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'


enable :sessions

get('/') do
  slim(:register, layout: :login_layout)
end

get('/showlogin') do
  slim(:login, layout: :login_layout)
end

get('/inventory') do
  slim(:inventory)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/the_egg.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result['pwdigest']
  id = result['id']

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/egg')
  else
    ''
  end
end

get('/egg') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/the_egg.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",id)
  slim(:"egg",locals:{users:result})
end

post('/user/new') do
  username = params[:username]
  password_confirm = params[:password_confirm]
  password = params[:password]

  if (password == password_confirm)
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/the_egg.db')
    db.execute('INSERT INTO users (username,pwdigest) VALUES (?,?)',username,password_digest)
    redirect('/')

  else
    "lösenorden matcher inte!"
  end
end

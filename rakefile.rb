#!/usr/bin/ruby

task :default => [:xcode, :osx, :brews, :casks, :zshell, :rbenv_setup, :ssh_keys, :dotfiles, :powerline, :pip, :git_config, :computer_name]

def curl what
  sh "curl -O #{what}" 
end

def brew what
  sh "brew install #{what}"
end

def cask what
  sh "brew cask install #{what}"
end

def in_dir dir
  pwd = Dir.pwd
  begin
    Dir.chdir dir
    yield if block_given?
  ensure
    Dir.chdir pwd 
  end
end

def soft_link(source, dst)
  sh "rm -fr #{dst}" 
  sh "ln -s #{source} #{dst}"
end

def git_config setting, what
  sh "git config --global #{setting} #{what}"
end

def ask_for what
  print what
  STDIN.gets.strip
end

def npm what
  sh "npm install -g #{what}"
end

desc "Installs xcode. Waits for input while installer is running"
task :xcode do
  begin 
    sh "xcode-select --install"
  rescue
    puts "Looks like xcode failed... was it already installed?"
  ensure
    puts "wait until xcode is installed..."
    STDIN.gets.strip
  end
end

desc "Sets some osx prefered settings"
task :osx do
  `git clone https://github.com/intelliplan/osx.git`
  in_dir "osx" do
    sh "./.osx"
    sh 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    sh "cp .bash_profile ~/"
  end
end

desc "Updates, upgrades and installs brews"
task :brews do
  sh "brew update"
  sh "brew upgrade"
  %w[awscli git vcsh mr jq ack openssl tree ucspi-tcp readline rbenv ruby-build 
    heroku-toolbelt nginx python python3 erlang tsung nmap sqlmap ngrep node mc mutt postgresql
    htop rlwrap weechat rbenv-gem-rehash leiningen wget tmux elixir elixir-build].each do |r|
    brew r
  end
  brew "imagemagick --with-webp"
  brew "caskroom/cask/brew-cask"
end

desc "Installs common casks"
task :casks do
  %w[mou dropbox spectacle 1password bittorrent-sync 
    firefox google-chrome caffeine gpgtools vagrant iterm2 vlc
     disk-inventory-x slack spotify flux ].each do |c|
    cask c
  end
  sh "brew tap caskroom/fonts"
end


desc "Installs global npm packages"
task :npms do
  %w[neochrome/marky bower].each do |p|
    npm p
  end  
end

task :ssh_keys do
  puts "Please sign in to your dropbox folder before you continue"
  STDIN.gets.strip
  home = Dir.home
  Dir.mkdir "#{home}/.ssh" unless Dir.exists? "#{home}/.ssh"
  ['heroku', 'github_rsa', 'id_rsa'].each do |key|
    soft_link "#{home}/Dropbox/Private/ssh/#{key}", "#{home}/.ssh/#{key}"
    sh "chmod 400 ~/.ssh/#{key}"
  end
end

task :dotfiles do
  `git clone https://github.com/kitofr/dotfiles.git` unless Dir.exists? "#{Dir.home}/dotfiles"
  in_dir "dotfiles" do
    sh "sudo gem install bundler"
    sh "bundle"
    sh "bundle exec rake"
  end
end

task :powerline do
  `git clone https://github.com/Lokaltog/powerline-fonts.git`
  in_dir "powerline-fonts" do
    sh "find . -name '*.[o,t]tf' -type f -print0 | xargs -0 -I % cp % $HOME/Library/Fonts/"
  end
end

task :pip do
  sh "pip install pygments"
end

desc "Installs Oh-my zshell"
task :zshell do
  sh "curl -L http://install.ohmyz.sh | sh"
end

desc "Install new ruby with rbenv"
task :rbenv_setup do
  sh "rbenv install 2.1.3"
  sh "rbenv rehash"
  sh "rbenv global 2.1.3"
  sh "gem install bundler" #otherwise bundler will be sudoed
end

desc "Sets minimum git config. Asks for input"
task :git_config do 
  git_config "core.editor", "/usr/bin/vim"
  git_config "push.default", "simple"
  git_config "core.autocrlf", "false"

  user = ask_for "Git user name: "
  git_config "user.name", "'#{user}'"
  email = ask_for "Git user email: "
  git_config "user.email", "'#{email}'"
end

desc "Sets computer name. Asks for input"
task :computer_name do
  # Set computer name (as done via System Preferences → Sharing)
  computer_name = ask_for "Computer name: "
  sh "sudo scutil --set ComputerName '#{computer_name}'"
  sh "sudo scutil --set HostName '#{computer_name}'"
  sh "sudo scutil --set LocalHostName '#{computer_name}'"
  sh "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string '#{computer_name.upcase}'"
end


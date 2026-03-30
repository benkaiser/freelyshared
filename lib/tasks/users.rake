namespace :users do
  desc "Change a user's password by email"
  task :set_password, [ :email, :password ] => :environment do |_t, args|
    email = args[:email]
    password = args[:password]
    abort "Usage: bin/rails users:set_password[email@example.com,newpassword]" if email.blank? || password.blank?
    abort "Password must be at least 6 characters" if password.length < 6

    member = ChurchMember.find_by(email: email)
    abort "No user found with email: #{email}" unless member

    member.update!(password: password, password_confirmation: password)
    puts "Password updated for #{member.name} (#{email})."
  end

  desc "Randomize passwords for all seed/example users (emails ending in @example.com)"
  task randomize_seed_passwords: :environment do
    example_users = ChurchMember.where("email LIKE ?", "%@example.com")

    if example_users.none?
      puts "No example users found."
      next
    end

    example_users.find_each do |member|
      new_password = SecureRandom.hex(16)
      member.update!(password: new_password, password_confirmation: new_password)
      puts "Randomized password for #{member.name} (#{member.email})"
    end

    puts "Done. #{example_users.count} example user passwords randomized."
  end
end

namespace :superadmin do
  desc "Grant superadmin access to a user by email"
  task :grant, [ :email ] => :environment do |_t, args|
    email = args[:email]
    abort "Usage: bin/rails superadmin:grant[email@example.com]" if email.blank?

    member = ChurchMember.find_by(email: email)
    abort "No user found with email: #{email}" unless member

    if member.superadmin?
      puts "#{member.name} (#{email}) is already a superadmin."
    else
      member.update!(superadmin: true)
      puts "Granted superadmin to #{member.name} (#{email})."
    end
  end

  desc "Revoke superadmin access from a user by email"
  task :revoke, [ :email ] => :environment do |_t, args|
    email = args[:email]
    abort "Usage: bin/rails superadmin:revoke[email@example.com]" if email.blank?

    member = ChurchMember.find_by(email: email)
    abort "No user found with email: #{email}" unless member

    if member.superadmin?
      member.update!(superadmin: false)
      puts "Revoked superadmin from #{member.name} (#{email})."
    else
      puts "#{member.name} (#{email}) is not a superadmin."
    end
  end

  desc "List all superadmins"
  task list: :environment do
    superadmins = ChurchMember.where(superadmin: true)
    if superadmins.any?
      puts "Superadmins:"
      superadmins.each do |m|
        puts "  #{m.name} <#{m.email}> (#{m.church&.name || 'no default church'})"
      end
    else
      puts "No superadmins configured."
    end
  end
end

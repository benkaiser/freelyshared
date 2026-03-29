# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Item categories are defined as constants on the Item model:
# Item::CATEGORIES = ["Tools", "Kitchen & Home", "Garden & Outdoor", "Books & Media",
#                      "Sports & Recreation", "Kids & Family", "Electronics", "Transport", "Other"]
# No separate categories table needed — they're stored as strings on items.

puts "Item categories available: #{Item::CATEGORIES.join(', ')}"

# Development seed data
if Rails.env.development?
  puts "Seeding development data..."

  # Create a test church with members
  church = Church.find_or_create_by!(name: "Grace Community Church") do |c|
    c.location_name = "Brisbane, QLD"
    c.latitude = -27.4698
    c.longitude = 153.0251
    c.status = "ready"
    c.ready_at = Time.current
  end

  # Enable admin approval for testing
  church.update!(require_admin_approval: true)

  # Create test members
  members = []
  [
    { name: "John Smith", email: "john@example.com", admin: true },
    { name: "Sarah Johnson", email: "sarah@example.com", admin: false },
    { name: "Mike Chen", email: "mike@example.com", admin: false },
    { name: "Emma Wilson", email: "emma@example.com", admin: false },
    { name: "David Brown", email: "david@example.com", admin: false }
  ].each do |attrs|
    is_admin = attrs.delete(:admin)
    member = ChurchMember.find_or_initialize_by(email: attrs[:email])
    member.assign_attributes(
      name: attrs[:name],
      church: church,
      password: "password123",
      password_confirmation: "password123",
      show_in_directory: true,
      admin: is_admin,
      approval_status: "approved"
    )
    member.save!
    members << member
  end

  # Create a pending test member
  pending_member = ChurchMember.find_or_initialize_by(email: "pending@example.com")
  pending_member.assign_attributes(
    name: "Pending User",
    church: church,
    password: "password123",
    password_confirmation: "password123",
    show_in_directory: true,
    approval_status: "pending"
  )
  pending_member.save!

  puts "Created #{members.count} approved members + 1 pending member."
  puts "Admin: john@example.com / password123"
  puts "Pending: pending@example.com / password123 (cannot log in)"

  # Create some items
  [
    { title: "Circular Saw", description: "DeWalt 7-1/4 inch circular saw. Great condition, includes extra blade.", category: "Tools", member: members[0] },
    { title: "Stand Mixer", description: "KitchenAid Artisan 5qt stand mixer. Perfect for baking.", category: "Kitchen & Home", member: members[1] },
    { title: "Camping Tent", description: "4-person dome tent, easy setup. Used twice.", category: "Sports & Recreation", member: members[2] },
    { title: "Kids' Bike", description: "16 inch kids bike with training wheels. Good for ages 4-6.", category: "Kids & Family", member: members[3] },
    { title: "Pressure Washer", description: "Karcher K5 pressure washer with hose and attachments.", category: "Garden & Outdoor", member: members[4] }
  ].each do |attrs|
    member = attrs.delete(:member)
    Item.find_or_create_by!(title: attrs[:title], church_member: member) do |item|
      item.assign_attributes(attrs.merge(church: church))
    end
  end

  # Create some services
  [
    { title: "Plumbing", description: "Licensed plumber, happy to help with minor repairs and installations.", contact_preference: "Call me on 0412 345 678", member: members[0] },
    { title: "Tutoring (Maths)", description: "High school maths tutor, years 7-12. Free for church members.", contact_preference: "Chat at church or text 0423 456 789", member: members[1] },
    { title: "Car Maintenance", description: "Basic car maintenance - oil changes, brake pads, tire rotation.", contact_preference: "See me at church", member: members[2] }
  ].each do |attrs|
    member = attrs.delete(:member)
    ServicesListing.find_or_create_by!(title: attrs[:title], church_member: member) do |service|
      service.assign_attributes(attrs.merge(church: church))
    end
  end

  # Create some needs
  [
    { title: "Help moving this Saturday", description: "Moving house this Saturday, need a few extra hands and a ute/trailer if possible.", contact_info: "Call Sarah 0423 456 789", member: members[1] },
    { title: "Looking for a drop saw", description: "Need to borrow a drop saw for a weekend deck project.", contact_info: "Text Mike 0434 567 890", member: members[2] }
  ].each do |attrs|
    member = attrs.delete(:member)
    Need.find_or_create_by!(title: attrs[:title], church_member: member) do |need|
      need.assign_attributes(attrs.merge(church: church, status: "open"))
    end
  end

  puts "Seed data created!"
  puts "Login: john@example.com / password123 (admin)"
end

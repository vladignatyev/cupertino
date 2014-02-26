command :'devices:list' do |c|
  c.syntax = 'ios devices:list'
  c.summary = 'Lists the Name and ID of Devices in the Provisioning Portal'
  c.description = ''

  c.action do |args, options|
    devices = try{agent.list_devices}

    number_of_devices = devices.compact.length
    number_of_additional_devices = devices.length - number_of_devices

    title = "Listing #{pluralize(number_of_devices, 'device')} "
    title += "(You can register #{pluralize(number_of_additional_devices, 'additional device')})" if number_of_additional_devices > 0

    table = Terminal::Table.new :title => title do |t|
      t << ["Device Name", "Device Identifier", "Enabled"]
      t.add_separator
      devices.compact.each do |device|
        t << [device.name, device.udid, device.enabled]
      end
    end

    table.align_column 2, :center

    puts table
  end
end

alias_command :devices, :'devices:list'

command :'devices:add' do |c|
  c.syntax = 'ios devices:add USER PASS UDID NAME [...]'
  c.summary = 'Adds the a device to the Provisioning Portal'
  c.description = ''

  c.action do |args, options|
    say_error "Missing arguments, expected USER PASS UDID NAME" and abort if args.nil? or args.empty?

    devices = []
    args.each do |arg|
      components = arg.strip.gsub(/"/, '').split(/\ /)
      device = Device.new
      user = components.first
      pass = components[1]
      device.udid = components[2]
      device.name = components.last
      say_warning "Invalid UDID: #{device.udid}" and next unless /\h{40}/ === device.udid
      devices << device
    end

    agent.set_account(user,pass)
    agent.add_devices(*devices)

    say_ok "Added #{pluralize(devices.length, 'device')}"
  end
end

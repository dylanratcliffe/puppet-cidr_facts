Facter.add(:cidr_facts) do
  require 'ipaddr'
  require 'json'

  cwd = File.expand_path(File.dirname(__FILE__))
  Facter.debug "cidr_facts using cwd #{cwd}"

  # Load all JSON files
  files = Dir["#{cwd}/cidr.d/*.json"]

  if files.empty?
    Facter.debug "cidr_facts found no files in cidr.d"
    setcode { nil }
  else
    setcode do
      data = files.map do |file|
        Facter.debug "Reading #{file}"
        JSON.parse(File.read(file))
      end

      data = data.reduce(:merge)

      # Sort based on mask size
      cidrs = data.sort_by do |cidr,facts|
        cidr.split('/')[1]
      end.reverse

      ip = IPAddr.new(Facter.value(:networking)['ip'])
      Facter.debug "Got current IP as #{ip.to_s}"

      # Return this
      cidrs.inject({}) do |final_hash, entry|
        cidr = IPAddr.new(entry[0])
        fact_entries = entry[1]

        if cidr.include?(ip)
          Facter.debug "Merging #{entry.to_s} into cidr_facts"
          final_hash.merge(fact_entries)
        else
          final_hash
        end
      end
    end
  end
end

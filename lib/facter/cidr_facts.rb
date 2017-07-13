Facter.add(:cidr_facts) do
  setcode do
    require 'ipaddr'
    require 'json'

    # Load all JSON files
    files = Dir['../cidr.d/*.json']

    data = files.map do |file|
      JSON.parse(File.read(file))
    end

    data = data.reduce(:merge)

    # Sort based on mask size
    cidrs = data.sort_by do |cidr,facts|
      cidr.split('/')[1]
    end.reverse

    ip = IPAddr.new(Facter.value(:networking)['ip'])

    # Return this
    cidrs.inject({}) do |final_hash, entry|
      cidr = IPAddr.new(entry[0])
      fact_entries = entry[1]

      if cidr.include?(ip)
        final_hash.merge(fact_entries)
      end
    end
  end
end

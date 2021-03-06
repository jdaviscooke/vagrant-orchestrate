require "optparse"
require "vagrant"

module VagrantPlugins
  module Orchestrate
    module Command
      class Push < Vagrant.plugin("2", :command)
        include Vagrant::Util

        def execute
          options = {}

          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant orchestrate push"
            o.separator ""

            o.on("--reboot", "Reboot a managed server after the provisioning step") do
              options[:reboot] = true
            end
          end

          # Parse the options
          argv = parse_options(opts)

          with_target_vms(argv, provider: :managed) do |machine|
            unless machine.name.to_s.start_with? "managed-"
              @logger.debug("Skipping machine #{machine.name}")
              next
            end

            machine.action(:up, options)
            machine.action(:provision, options)
            machine.action(:reload, options) if options[:reboot]
            machine.action(:destroy, options)
          end
        end
      end
    end
  end
end

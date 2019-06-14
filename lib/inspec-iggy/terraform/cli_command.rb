# Terraform CLI command and options

require 'inspec/plugin/v2'

require 'inspec-iggy/version'
require 'inspec-iggy/profile_helper'
require 'inspec-iggy/terraform/parser'

module InspecPlugins::Iggy
  module Terraform
    class CliCommand < Inspec.plugin(2, :cli_command)
      subcommand_desc 'terraform SUBCOMMAND ...', 'Generate an InSpec profile from Terraform'

      # Thor.map(Hash) allows you to make aliases for commands.
      map('-v' => 'version')         # Treat `inspec terraform -v`` as `inspec terraform version`
      map('--version' => 'version')  # Treat `inspec terraform -version`` as `inspec terraform version`

      desc 'version', 'Display version information', hide: true
      def version
        say("Iggy v#{InspecPlugins::Iggy::VERSION}")
      end

      option :debug,
             desc: 'Verbose debugging messages',
             type: :boolean,
             default: false

      option :copyright,
             desc: 'Name of the copyright holder',
             default: 'The Authors'

      option :email,
             desc: 'Email address of the author',
             default: 'you@example.com'

      option :license,
             desc: 'License for the profile',
             default: 'Apache-2.0'

      option :maintainer,
             desc: 'Name of the copyright holder',
             default: 'The Authors'

      option :summary,
             desc: 'One line summary for the profile',
             default: 'An InSpec Compliance Profile'

      option :title,
             desc: 'Human-readable name for the profile',
             default: 'InSpec Profile'

      option :version,
             desc: 'Specify the profile version',
             default: '0.1.0'

      option :overwrite,
             desc: 'Overwrites existing profile directory',
             type: :boolean,
             default: false

      option :name,
             aliases: '-n',
             required: true,
             desc: 'Name of profile to be generated'

      option :tfstate,
             aliases: '-t',
             desc: 'Specify path to the input terraform.tfstate',
             default: 'terraform.tfstate'

      option :platform,
             desc: 'The InSpec platform providing the necessary resources (aws, azure, or gcp)'

      option :resourcepath,
             desc: 'Specify path to the InSpec Resource Pack providing the necessary resources'

      desc 'generate [options]', 'Generate InSpec compliance controls from terraform.tfstate'
      def generate
        Inspec::Log.level = :debug if options[:debug]
        platform = options[:platform]
        resource_path = options[:resourcepath]
        # require validation that if platform or resourcepath are passed, both are available
        if platform or resource_path
          unless platform and resource_path
            self.error "You must pass both --platform and --resourcepath if using either"
            self.exit(1)
          end
        end
        generated_controls = InspecPlugins::Iggy::Terraform::Parser.parse_generate(options[:tfstate], resource_path)
        printable_controls = InspecPlugins::Iggy::InspecHelper.tf_controls(options[:title], generated_controls, platform)
        InspecPlugins::Iggy::ProfileHelper.render_profile(self.ui, options, options[:tfstate], printable_controls, platform)
        exit 0
      end

      # disabled extract functionality
      # desc 'extract [options]', 'Extract tagged InSpec profiles from terraform.tfstate'
      # def extract
      #   Inspec::Log.level = :debug if options[:debug]
      #   extracted_profiles = InspecPlugins::Iggy::Terraform::Parser.parse_extract(options[:tfstate])
      #   puts InspecPlugins::Iggy::InspecHelper.print_commands(extracted_profiles)
      #   exit 0
      # end
    end
  end
end

module Fastlane
  module Actions
    class SentryUploadDifAction < Action
      def self.run(params)
        require 'shellwords'

        Helper::SentryHelper.check_sentry_cli!
        Helper::SentryConfig.parse_api_params(params)

        # no_debug
        # no_sources
        # ids
        # require_all
        # symbol_maps
        # derived_data
        # no_zips
        # info_plist
        # no_reprocessing
        # force_foreground
        # include_sources
        # wait
        # upload_symbol_maps

        command = [
          "sentry-cli",
          "upload-dif"
        ]
        command.push('--paths').push(params[:paths]) unless params[:paths].nil?
        command.push('--types').push(params[:types]) unless params[:types].nil?
        command.push('--no_unwind') unless params[:no_unwind].nil?

        Helper::SentryHelper.call_sentry_cli(command)
        UI.success("Successfully ran upload-dif")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload debugging information files."
      end

      def self.details
        [
          "Files can be uploaded using the upload-dif command. This command will scan a given folder recursively for files and upload them to Sentry.",
          "See https://docs.sentry.io/platforms/native/data-management/debug-files/upload/ for more information."
        ].join(" ")
      end

      def self.available_options
        Helper::SentryConfig.common_api_config_items + [
          FastlaneCore::ConfigItem.new(key: :paths,
                                       description: "A path to search recursively for symbol files"),
          FastlaneCore::ConfigItem.new(key: :types,
                                       short_option: "-t",
                                       description: "Only consider debug information files of the given \
                                       type.  By default, all types are considered",
                                       optional: true,
                                       verify_block: proc do |value|
                                        UI.user_error! "Invalid value '#{value}'" unless ['dsym', 'elf', 'breakpad', 'pdb', 'pe', 'sourcebundle', 'bcsymbolmap'].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_unwind,
                                       description: "Do not scan for stack unwinding information. Specify \
                                       this flag for builds with disabled FPO, or when \
                                       stackwalking occurs on the device. This usually \
                                       excludes executables and dynamic libraries. They might \
                                       still be uploaded, if they contain additional \
                                       processable information (see other flags)",
                                       is_string: false,
                                       optional: true),
          # FastlaneCore::ConfigItem.new(key: :started,
          #                              description: "Optional unix timestamp when the deployment started",
          #                              is_string: false,
          #                              optional: true),
          # FastlaneCore::ConfigItem.new(key: :finished,
          #                              description: "Optional unix timestamp when the deployment finished",
          #                              is_string: false,
          #                              optional: true),
          # FastlaneCore::ConfigItem.new(key: :time,
          #                              short_option: "-t",
          #                              description: "Optional deployment duration in seconds. This can be specified alternatively to `started` and `finished`",
          #                              is_string: false,
          #                              optional: true),
          # FastlaneCore::ConfigItem.new(key: :app_identifier,
          #                              short_option: "-a",
          #                              env_name: "SENTRY_APP_IDENTIFIER",
          #                              description: "App Bundle Identifier, prepended with the version.\nFor example bundle@version",
          #                              optional: true)
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["denrase"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
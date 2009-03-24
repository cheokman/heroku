module Heroku::Command
	class Config < BaseWithApp
		def index
			long = args.delete('--long')
			if args.empty?
				vars = heroku.config_vars(app)
				display_vars(vars, long)
			elsif args.size == 1 && !args.first.include?('=')
				var = heroku.config_vars(app).select { |k, v| k == args.first.upcase }
				display_vars(var, long)
			elsif args.all? { |a| a.include?('=') }
				vars = args.inject({}) do |vars, arg|
					key, value = arg.split('=')
					vars[key] = value
					vars
				end

				display "Setting #{vars.inspect} and restarting app..."
				heroku.set_config_vars(app, vars)
				display "done"
			else
				raise CommandFailed, "Usage: heroku config <key> or heroku config <key>=<value>"
			end
		end

		def unset
			display "Unsetting #{args.first} and restarting app..."
			heroku.unset_config_var(app, args.first)
			display "done"
		end

		def reset
			display "Reseting all config vars and restarting app..."
			heroku.reset_config_vars(app)
			display "done"
		end

		protected
			def restart_app
				display "Restarting app..."
				heroku.restart(app)
				display "done"
			end

			def display_vars(vars, long)
				max_length = vars.map { |v| v[0].size }.max
				vars.each do |k, v|
					spaces = ' ' * (max_length - k.size)
					display "#{k}#{spaces} => #{format(v, long)}"
				end
			end

			def format(value, long=false)
				return value if long || value.size < 36
				value[0, 16] + '...' + value[-16, 16]
			end
	end
end

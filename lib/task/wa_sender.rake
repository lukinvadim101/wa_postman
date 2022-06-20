# frozen_string_literal: true

# require 'wa_sender'

desc 'WA Posts Manager'
task :send, [:path] do |_t, args|
  options = {}
  opts = OptionParser.new

  opts.on('-p', '--path ARG', String) { |path| options[:path] = path }
  opts.on('-t', '--term ARG', String) { |term| options[:term] = term }

  args = opts.order!(ARGV) {}
  opts.parse!(args)

  store = Store.new(CsvManager.new.read(options[:path])).data
  sender = Sender.new(store)
  sender.execute(options[:term])
  # sender.find_mailing_errors
end

# rake send -- --path data/exm.csv --term advance
# rake send -- --path data/exm.csv --term due
# rake send -- --path data/exm.csv --term overdue




until dispatcher.empty? and scheduler.empty?
  time_elapsed = time_operation do
    wait_until { !dispatcher.full? }
    request = scheduler.next_integration_request(dispatcher.busy_filter)
    dispatcher.start_integrating(request) if request
    dispatcher.completed_integrations.each do |integration|
      scheduler.complete_integration_request(integration.request)
      notifier.notify(integration)
    end
  end
  if time_elapsed > x
    scheduler.read_queue
  elsif time_elapsed < 0.1
    sleep 0.1
  end
end

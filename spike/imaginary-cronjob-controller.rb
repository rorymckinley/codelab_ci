while request = scheduler.next_integration_request(dispatcher.busy_filter)
  time_elapsed = time_operation do
    dispatcher.start_integrating(request)
    dispatcher.completed_integrations.each do |integration|
      scheduler.complete_integration_request(integration.request)
      notifier.notify(integration)
    end
  end
  if time_elapsed > x
    scheduler.read_queue
  elsif time_elapsed < 1
    sleep 1
  end
end

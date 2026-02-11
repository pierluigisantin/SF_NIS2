trigger AccountTrigger on Account (after insert, after update) {
    AccountHandler.handleAfter(Trigger.new);
}

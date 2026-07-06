enum JobStatus {
  assigned,
  inProgress,
  waitingForParts,
  onHold,
  readyForDelivery,
  completed,
  cancelled;

  static JobStatus fromDb(String value) {
    switch (value) {
      case 'assigned':
        return JobStatus.assigned;
      case 'in_progress':
        return JobStatus.inProgress;
      case 'waiting_for_parts':
        return JobStatus.waitingForParts;
      case 'on_hold':
        return JobStatus.onHold;
      case 'ready_for_delivery':
        return JobStatus.readyForDelivery;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        return JobStatus.assigned;
    }
  }

  String toDb() {
    switch (this) {
      case JobStatus.assigned:
        return 'assigned';
      case JobStatus.inProgress:
        return 'in_progress';
      case JobStatus.waitingForParts:
        return 'waiting_for_parts';
      case JobStatus.onHold:
        return 'on_hold';
      case JobStatus.readyForDelivery:
        return 'ready_for_delivery';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.waitingForParts:
        return 'Waiting for Parts';
      case JobStatus.onHold:
        return 'On Hold — Awaiting Approval';
      case JobStatus.readyForDelivery:
        return 'Ready for Delivery';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }
}

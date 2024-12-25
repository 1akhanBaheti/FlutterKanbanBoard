enum GroupMoreAction {
  editTitle('Edit title'),
  createNewTask('Create new task'),
  deleteGroup('Delete group');

  final String label;

  const GroupMoreAction(this.label);
}

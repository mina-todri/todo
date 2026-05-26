import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

class TaskTile extends StatefulWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = AppColors.priorityColors[task.priority]!;

    return FadeTransition(
      opacity: _fade,
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        onDismissed: (_) => widget.onDelete(),
        child: GestureDetector(
          onTap: widget.onEdit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: task.isDone
                  ? AppColors.surface.withOpacity(0.5)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isDone
                    ? AppColors.border.withOpacity(0.5)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                _buildPriorityIndicator(task, priorityColor),
                const SizedBox(width: 14),
                _buildCheckButton(task),
                const SizedBox(width: 14),
                Expanded(child: _buildTaskDetails(task)),
                if (!task.isDone) _buildPriorityBadge(task, priorityColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline_rounded,
          color: AppColors.danger, size: 24),
    );
  }

  Widget _buildPriorityIndicator(Task task, Color color) {
    return Container(
      width: 4,
      height: 44,
      decoration: BoxDecoration(
        color: task.isDone ? AppColors.border : color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCheckButton(Task task) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.isDone ? AppColors.success : Colors.transparent,
          border: Border.all(
            color: task.isDone ? AppColors.success : AppColors.textSecondary,
            width: 2,
          ),
        ),
        child: task.isDone
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
            : null,
      ),
    );
  }

  Widget _buildTaskDetails(Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: task.isDone ? AppColors.textSecondary : AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
            decorationColor: AppColors.textSecondary,
          ),
          child: Text(task.title),
        ),
        if (task.note != null && task.note!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            task.note!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityBadge(Task task, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        task.priority.name[0].toUpperCase() + task.priority.name.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

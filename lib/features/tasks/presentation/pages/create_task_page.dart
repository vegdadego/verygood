import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';

/// Page for creating a new task.
///
/// This page demonstrates modern Flutter UI best practices including:
/// - Form validation with TextFormField
/// - Loading states with CircularProgressIndicator
/// - Error handling with SnackBar
/// - Clean, modern visual design
/// - Proper async state management with BLoC
class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handle task submission
  ///
  /// This method:
  /// 1. Validates the form
  /// 2. Shows loading indicator
  /// 3. Makes API call via DioClient to create the task
  /// 4. Shows success/error messages
  /// 5. Navigates back on success
  Future<void> _submitTask() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create task via DioClient
      final dio = DioClient();
      await dio.post(
        '/posts',
        {
          'title': _titleController.text.trim(),
          'body': _descriptionController.text.trim(),
        },
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSuccessSnackBar(),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildErrorSnackBar(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  SnackBar _buildSuccessSnackBar() {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 12),
          Text('Task created successfully!'),
        ],
      ),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
    );
  }

  SnackBar _buildErrorSnackBar(String error) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Create New Task'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTitleField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header section with icon and title
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create a New Task',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add details to get started',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Title input field with modern glassmorphism design
  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          labelText: 'Task Title',
          hintText: 'e.g., Finish Flutter assignment',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a task title';
          }
          if (value.trim().length < 3) {
            return 'Title must be at least 3 characters';
          }
          return null;
        },
        enabled: !_isLoading,
      ),
    );
  }

  /// Description input field with modern glassmorphism design
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Description',
          hintText: 'Add details about your task...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a description';
          }
          if (value.trim().length < 5) {
            return 'Description must be at least 5 characters';
          }
          return null;
        },
        enabled: !_isLoading,
      ),
    );
  }

  /// Submit button with modern design and loading state
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitTask,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667eea),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Create Task',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/models/category.dart';
import 'package:todolist/models/label.dart';
import 'package:todolist/models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/category_provider.dart';
import '../providers/label_provider.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Indeks tab yang aktif
  String searchQuery = "";
  int _deadlineCount = 0; // Jumlah deadline mendekati

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TodoProvider>(context, listen: false).fetchTodos();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDeadlines());
  }

  void _checkDeadlines() {
    final todos = Provider.of<TodoProvider>(context, listen: false).todos;
    final now = DateTime.now();

    int count = todos.where((todo) {
      final deadline = DateTime.parse(todo.deadline); // Pastikan format tanggal sesuai
      final difference = deadline.difference(now).inDays;
      return difference == 0 || difference == 1; // Hari ini atau besok
    }).length;

    setState(() {
      _deadlineCount = count;
    });
  }

  @override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Todo List",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: _deadlineCount > 0,
            badgeContent: Text(
              '$_deadlineCount',
              style: TextStyle(color: Colors.white),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ada $_deadlineCount todo mendekati deadline!')),
                );
              },
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[300],
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.blue.shade600,
          ),
          tabs: [
            Tab(text: "Todos"),
            Tab(text: "Categories"),
            Tab(text: "Labels"),
          ],
        ),
      ),
      body: TabBarView(
        children: [_buildTodoTab(), _buildCategoryTab(), _buildLabelTab()],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        elevation: 5,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (_currentIndex == 0) {
            _showAddTodoDialog();
          } else if (_currentIndex == 1) {
            _showAddCategoryDialog();
          } else {
            _showAddLabelDialog();
          }
        },
      ),
    ),
  );
}

  // ==============================
  // TAB TODOS
  // ==============================
Widget _buildTodoTab() {
  TextEditingController searchController = TextEditingController();
  String selectedStatusOption = 'Semua'; // Default value untuk menampilkan semua status

  return Consumer<TodoProvider>(
    builder: (context, todoProvider, child) {
      List<Todo> filteredTodos =
          todoProvider.todos.where((todo) {
            final query = searchController.text.toLowerCase();
            bool matchesStatus = selectedStatusOption == 'Semua' || todo.status.toLowerCase() == selectedStatusOption.toLowerCase();
            bool matchesSearch = todo.title.toLowerCase().contains(query) ||
                todo.description!.toLowerCase().contains(query) ||
                todo.label.title.toLowerCase().contains(query) ||
                todo.category.title.toLowerCase().contains(query) ||
                todo.status.toLowerCase().contains(query) ||
                todo.deadline.toLowerCase().contains(query);

            return matchesStatus && matchesSearch; // Filter berdasarkan status dan pencarian
          }).toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                hintText: 'Cari tugas... ',
                filled: true,
                fillColor: Colors.blue.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => todoProvider.notifyListeners(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField(
              value: selectedStatusOption,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.blue.shade100,
              ),
              items: ['Semua', 'Rendah', 'Sedang', 'Tinggi']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedStatusOption = value!;
                todoProvider.notifyListeners(); // Memberi tahu perubahan
              },
            ),
          ),
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
                    child: Text(
                      'Data Tidak Ada',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Deskripsi: ${todo.description}"),
                              Text("Label: ${todo.label.title}"),
                              Text("Category: ${todo.category.title}"),
                              Text("Status: ${todo.status}"),
                              Text("Deadline: ${todo.deadline}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.lightGreen),
                                onPressed: () => _showEditTodoDialog(todo),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red.shade700),
                                onPressed: () => _showDeleteDialog(
                                  () => todoProvider.deleteTodo(todo.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}



  // ==============================
  // MODAL EDIT TODO
  // ==============================
  void _showEditTodoDialog(Todo todo) {
    final TextEditingController _titleController = TextEditingController(
      text: todo.title,
    );
    final TextEditingController _descriptionController = TextEditingController(
      text: todo.description,
    );
    final TextEditingController _deadlineController = TextEditingController(
      text: todo.deadline,
    );

    // Make sure category and label are not null
    String _selectedCategory = todo.category?.id?.toString() ?? "0";
    String _selectedLabel = todo.label?.id?.toString() ?? "0";
    String _selectedStatus = todo.status;
    DateTime? _selectedDate = DateTime.tryParse(todo.deadline);

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Todo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Nama Todo",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory != "0" ? _selectedCategory : null,
                  hint: Text("Pilih Kategori"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items:
                      categoryProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id.toString(),
                          child: Text(category.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedCategory = value ?? "0";
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedLabel != "0" ? _selectedLabel : null,
                  hint: Text("Pilih Label"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items:
                      labelProvider.labels.map((label) {
                        return DropdownMenuItem(
                          value: label.id.toString(),
                          child: Text(label.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedLabel = value ?? "0";
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items:
                      ['rendah', 'sedang', 'tinggi'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedStatus = value!;
                  },
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _deadlineController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Deadline",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_deadlineController.text),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Simpan"),
              onPressed: () {
                final int? categoryId = int.tryParse(_selectedCategory);
                final int? labelId = int.tryParse(_selectedLabel);

                // Make sure category and label are not null or 0
                if (categoryId == null || categoryId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Kategori tidak valid")),
                  );
                  return;
                }
                if (labelId == null || labelId == 0) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Label tidak valid")));
                  return;
                }

                Provider.of<TodoProvider>(
                  context,
                  listen: false,
                ).updateTodo(todo.id, {
                  "title": _titleController.text.trim(),
                  "description": _descriptionController.text.trim(),
                  "category_id": categoryId,
                  "label_id": labelId,
                  "status": _selectedStatus,
                  "deadline": _deadlineController.text.trim(),
                });

                if (_selectedDate != null) {}

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // TAB CATEGORIES
  // ==============================
  Widget _buildCategoryTab() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.categories.isEmpty) {
          return Center(child: Text("Belum ada kategori!"));
        }
        return ListView.builder(
          itemCount: categoryProvider.categories.length,
          itemBuilder: (context, index) {
            final category = categoryProvider.categories[index];
            return _buildListItem(
              category.title,
              () => _showDeleteDialog(
                () => categoryProvider.deleteCategory(category.id),
              ),
              onEdit: () => _showEditCategoryDialog(category),
            );
          },
        );
      },
    );
  }

  // ==============================
  // MODAL EDIT CATEGORY
  // ==============================
  void _showEditCategoryDialog(Category category) {
    final TextEditingController _controller = TextEditingController(
      text: category.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Category"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Nama Category"),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Simpan"),
              onPressed: () {
                Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                ).updateCategory(category.id.toString(), {
                  "title": _controller.text.trim(),
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // TAB LABELS
  // ==============================
  Widget _buildLabelTab() {
    return Consumer<LabelProvider>(
      builder: (context, labelProvider, child) {
        if (labelProvider.labels.isEmpty) {
          return Center(child: Text("Belum ada label!"));
        }
        return ListView.builder(
          itemCount: labelProvider.labels.length,
          itemBuilder: (context, index) {
            final label = labelProvider.labels[index];
            return _buildListItem(
              label.title,
              () =>
                  _showDeleteDialog(() => labelProvider.deleteLabel(label.id)),
              onEdit: () => _showEditLabelDialog(label),
            );
          },
        );
      },
    );
  }

  // ==============================
  // MODAL EDIT LABEL
  // ==============================
  void _showEditLabelDialog(Label label) {
    final TextEditingController _controller = TextEditingController(
      text: label.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Label"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Nama Label"),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Simpan"),
              onPressed: () async {
                final updatedTitle = _controller.text.trim();

                if (updatedTitle.isNotEmpty) {
                  await Provider.of<LabelProvider>(
                    context,
                    listen: false,
                  ).updateLabel(label.id.toString(), {"title": updatedTitle});
                  // Perbarui state agar perubahan langsung terlihat
                  setState(() {});
                  // Tutup dialog
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // WIDGET LIST ITEM
  // ==============================
  Widget _buildListItem(
    String title,
    VoidCallback onDelete, {
    VoidCallback? onEdit,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.lightGreen),
                onPressed: onEdit,
              ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // MODAL KONFIRMASI HAPUS
  // ==============================
  void _showDeleteDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus item ini?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Hapus"),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // MODAL TAMBAH TODO
  // ==============================
  void _showAddTodoDialog() {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _deadlineController = TextEditingController();

    DateTime? _selectedDeadline;
    String? _selectedCategory;
    String? _selectedLabel;
    String _selectedStatus = "rendah"; // Default status

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Todo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Nama Todo",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Pilih Kategori",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  value: _selectedCategory,
                  items:
                      categoryProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id.toString(),
                          child: Text(category.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedCategory = value;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Pilih Label",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  value: _selectedLabel,
                  items:
                      labelProvider.labels.map((label) {
                        return DropdownMenuItem(
                          value: label.id.toString(),
                          child: Text(label.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedLabel = value;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  value: _selectedStatus,
                  items:
                      ['rendah', 'sedang', 'tinggi'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedStatus = value!;
                  },
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDeadline = pickedDate;
                        _deadlineController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Deadline",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDeadline == null
                          ? "Pilih Deadline"
                          : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                final String title = _titleController.text.trim();
                final String description = _descriptionController.text.trim();

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Judul tidak boleh kosong")),
                  );
                  return;
                }

                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih kategori terlebih dahulu")),
                  );
                  return;
                }

                if (_selectedLabel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih label terlebih dahulu")),
                  );
                  return;
                }

                if (_selectedDeadline == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih deadline terlebih dahulu")),
                  );
                  return;
                }

                String formattedDeadline = DateFormat(
                  'yyyy-MM-dd',
                ).format(_selectedDeadline!);

                Provider.of<TodoProvider>(context, listen: false).addTodo({
                  "title": title,
                  "description": description,
                  "category_id": _selectedCategory,
                  "label_id": _selectedLabel,
                  "status": _selectedStatus,
                  "deadline": formattedDeadline,
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Category"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Nama Category"),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                final String title = _controller.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).addCategory({"title": title});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // MODAL TAMBAH LABEL
  // ==============================
  void _showAddLabelDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Label"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Nama Label"),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                final String title = _controller.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<LabelProvider>(
                    context,
                    listen: false,
                  ).addLabel({"title": title});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

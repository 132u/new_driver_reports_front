import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/api/report_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  File? selectedImage;
  List<File> selectedImages = [];
  Future<void> pickImages() async {
    final picker = ImagePicker();

    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        selectedImages = pickedFiles.map((e) => File(e.path)).toList();
      });

      print("SELECTED: ${selectedImages.length} images");
    }
  }

  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final clientController = TextEditingController();

  final reportService = ReportService();

  DateTime selectedDate = DateTime.now();

  int paymentType = 0;
  int moneyHolder = 0;

  Future<void> createReport() async {
    if (!_formKey.currentState!.validate()) return;
    List<String> imagePaths = [];

    if (selectedImages.isNotEmpty) {
      imagePaths = await reportService.uploadImages(selectedImages);
    }
    final data = {
      "reportDate": selectedDate.toIso8601String(),
      "price": int.parse(priceController.text),
      "description": descriptionController.text,
      "clientName": clientController.text,
      "paymentType": paymentType,
      "moneyHolder": paymentType == 0 ? moneyHolder : 1,
      "imagePath": imagePaths
    };
    try {
      await reportService.createReport(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Отчет успешно создан")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Создать отчет")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📅 DATE
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Дата отчета"),
                subtitle: Text(
                  selectedDate.toString().split(" ")[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  if (date != null) {
                    final now = DateTime.now();

                    if (date.isAfter(
                      DateTime(now.year, now.month, now.day),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Нельзя выбрать дату в будущем"),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              // 💰 PRICE
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: "Сумма",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Введите сумму";
                  }
                  if (int.tryParse(v) == null) {
                    return "Только числа";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // 🧾 CLIENT
              TextFormField(
                controller: clientController,
                decoration: const InputDecoration(
                  labelText: "Заказчик",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              // 📝 DESCRIPTION
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Описание",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              // 💳 PAYMENT TYPE
              DropdownButtonFormField<int>(
                value: paymentType,
                decoration: const InputDecoration(
                  labelText: "Тип платежа",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Cash")),
                  DropdownMenuItem(value: 1, child: Text("Cashless VAT")),
                  DropdownMenuItem(value: 2, child: Text("Cashless no VAT")),
                ],
                onChanged: (value) {
                  setState(() {
                    paymentType = value!;
                  });
                },
              ),

              const SizedBox(height: 10),

              // 👛 MONEY HOLDER
              if (paymentType == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Деньги у:"),
                    RadioListTile(
                      title: const Text("Водитель"),
                      value: 0,
                      groupValue: moneyHolder,
                      onChanged: (v) {
                        setState(() {
                          moneyHolder = v!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: const Text("Виктор"),
                      value: 1,
                      groupValue: moneyHolder,
                      onChanged: (v) {
                        setState(() {
                          moneyHolder = v!;
                        });
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Фото"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImages.isEmpty
                          ? const Center(child: Text("Выбрать фото"))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedImages.length,
                              itemBuilder: (context, index) {
                                final file = selectedImages[index];

                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      file,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
              // 🚀 BUTTON
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: createReport,
                  child: const Text("Создать отчет"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

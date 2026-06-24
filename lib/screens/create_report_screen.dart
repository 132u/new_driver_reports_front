import 'dart:convert';
import 'package:driver_reports_app/screens/home_screen.dart' show ReportDto;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:driver_reports_app/core/constants/api_constants.dart';
import 'package:driver_reports_app/screens/create_financial_operation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/api/report_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateReportScreen extends StatefulWidget {
  final String token;
  final String role;
  final ReportDto? report;
  const CreateReportScreen({
    super.key,
    required this.token,
    required this.role,
    this.report,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  bool get isEdit => widget.report != null;
  List<String> existingPhotos = [];
  final _formKey = GlobalKey<FormState>();
  File? selectedImage;
  List<Uint8List> selectedImages = [];
  List<UserDto> drivers = [];
  String? selectedDriverId;
  //String? currentUserId;
  bool get isAdmin => widget.role == 'Admin';

  Future<void> pickImages() async {
    final picker = ImagePicker();

    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      final bytesList = await Future.wait(
        pickedFiles.map((e) => e.readAsBytes()),
      );

      setState(() {
        selectedImages = bytesList;
      });

      print("SELECTED: ${selectedImages.length} images");
    }
  }

  @override
  void initState() {
    super.initState();

    if (isAdmin) {
      loadDrivers();
    }

    if (widget.report != null) {
      final report = widget.report!;

      priceController.text = report.price.toString();

      clientController.text = report.clientName;

      descriptionController.text = report.description;

      paymentType = report.paymentType;

      moneyHolder = report.moneyHolder;
      existingPhotos = report.imagePaths;

      selectedDate = DateTime.parse(report.reportDate);
    }
  }

  Future<void> loadDrivers() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/all'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);

      final result = json
          .map((e) => UserDto.fromJson(e))
          .where((x) => x.role == "1")
          .toList();

      setState(() {
        drivers = result;

        if (widget.report != null) {
          selectedDriverId = widget.report!.driverId;
        } else if (drivers.isNotEmpty) {
          selectedDriverId = drivers.first.id;
        }
      });
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
    List<String> imagePaths = [...existingPhotos];

    if (isAdmin && selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Выберите водителя"),
        ),
      );
      return;
    }
    if (selectedImages.isNotEmpty) {
      final uploaded = await reportService.uploadImages(selectedImages);

      imagePaths.addAll(uploaded);
    }
    final data = {
      "driverId": isAdmin ? selectedDriverId : null,
      "reportDate": selectedDate.toLocal().toString().split(' ')[0],
      "price": int.parse(priceController.text),
      "description": descriptionController.text,
      "clientName": clientController.text,
      "paymentType": paymentType,
      "moneyHolder": paymentType == 0 ? moneyHolder : 1,
      "imagePaths": imagePaths
    };
    try {
      print("selectedDriverId = $selectedDriverId");
      print(jsonEncode(data));
      if (isEdit) {
        await reportService.updateReport(
          widget.report!.id,
          data,
        );
      } else {
        await reportService.createReport(data);
      }

      print('REPORT CREATED');
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
      appBar: AppBar(
        title: Text(
          isEdit ? "Редактировать отчет" : "Создать отчет",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (isAdmin)
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDriverId,
                  items: drivers.map((d) {
                    return DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(d.userName),
                    );
                  }).toList(),
                  onChanged: drivers.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            selectedDriverId = value;
                          });
                        },
                ),

              if (isAdmin) const SizedBox(height: 16),

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
                  DropdownMenuItem(value: 0, child: Text("Наличные")),
                  DropdownMenuItem(value: 1, child: Text("Безнал с НДС")),
                  DropdownMenuItem(value: 2, child: Text("Безнал без НДС")),
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
                      child: (selectedImages.isEmpty && existingPhotos.isEmpty)
                          ? const Center(
                              child: Text("Выбрать фото"),
                            )
                          : ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // существующие фото
                                ...existingPhotos.map(
                                  (photo) => Container(
                                    margin: const EdgeInsets.all(8),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            '${ApiConstants.serverUrl}$photo',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.red,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              iconSize: 14,
                                              color: Colors.white,
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  existingPhotos.remove(photo);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // новые фото
                                ...selectedImages.map(
                                  (bytes) => Container(
                                    margin: const EdgeInsets.all(8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        bytes,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                  onPressed:
                      isAdmin && selectedDriverId == null ? null : createReport,
                  child: Text(
                    isEdit ? "Сохранить" : "Создать отчет",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

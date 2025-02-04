import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lostandfound/constants/categories.dart';
import 'package:lostandfound/models/user.dart';
import 'package:lostandfound/models/userProf.dart';
import 'package:lostandfound/services/backend_manager.dart';
import 'package:lostandfound/services/image_picker.dart';
import 'package:lostandfound/settings/colors.dart';
import 'package:lostandfound/widgets/form_widgets.dart';
import 'package:lostandfound/widgets/map.dart';



class AddPublicationForm extends StatefulWidget {
  const AddPublicationForm({Key? key}) : super(key: key);

  @override
  State<AddPublicationForm> createState() => _AddPublicationFormState();
}

class _AddPublicationFormState extends State<AddPublicationForm> {

  //Form Validation variables
  final _formKey = GlobalKey<FormState>();

  var validator = (value) {
    if (value == null || value.isEmpty) {
      return 'Ce champs est obligatoire';
    }
    return null;
  };

  //Date variables
  DateTime _date = DateTime.now();

  //Images variables
  ImagePickerService _imagePickerService = ImagePickerService();
  List<File> _photos = [];

  //Controllers
  TextEditingController _locationController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  //Category varaibles
  String _category = "";

  //Type variables
  String _type = "lost";

  //Location variables
  late LatLng _location;

  @override
  Widget build(BuildContext context) {

    initializeDateFormatting();

    //Showing Map function
    _show() async {
      var loc = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return MapScreen();
          }
      );
      setState(() {
        _locationController.text = loc[0];
        _location = loc[1];
      });
    }

    //Date Controller
    TextEditingController _dateController = TextEditingController(text: DateFormat('EEEE d MMMM yyyy','fr').format(_date));

    //Sizes
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: primaryBackground,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),),
          title: Text("Publication d'objet"),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("L'objet déclaré est : "),
                      SizedBox(width: 20,),
                      Text("Lost"),
                      Radio<String>(
                        value: "lost",
                        groupValue: _type,
                        onChanged: (item){
                          setState(() {
                            _type= item!;
                          });
                        },
                      ),
                      Text("Found"),
                      Radio<String>(
                        value: "found",
                        groupValue: _type,
                        onChanged: (item){
                          setState(() {
                            _type= item!;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),

                  DropDown(validator: validator, items : categories,onchanged: (item){ setState(() { _category = item.toString(); });} ),

                  SizedBox(height: 20,),

                  TextInputField(controller: _titleController,validator: validator, maxLines: 1,label: "Titre"),

                  SizedBox(height: 20,),

                  TextInputField(controller: _descriptionController,validator: validator, maxLines: 6,label: "Description"),

                  SizedBox(height: 20,),

                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      label: Text("Date"),
                      fillColor: Color(0xfffafafa),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.date_range_outlined),
                        onPressed: () async {
                          _date = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2012),
                            lastDate: DateTime.now(),
                            cancelText: "Annuler",
                            confirmText: "Confirmer",
                            helpText: "Choisir la date",
                            errorFormatText: "Format invalide",
                            errorInvalidText: "Texte invalide",
                            fieldLabelText: "Entrer la date",
                          ) ?? DateTime.now();
                          setState(() {
                            _dateController.text = DateFormat('EEEE d MMMM yyyy','fr').format(_date);//_date .toString();
                          });
                        },
                      ),
                    ),

                  ),

                  SizedBox(height: 30,),

                  SizedBox(
                    height: _photos.isEmpty ? 0 :((_photos.length-1)~/2+1)*160,
                    child: _photos==null ? Text("") : GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _photos.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (BuildContext context, int index){
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xffd4d8dc), width: 2),
                              ),
                              child: Image.file(_photos[index], fit: BoxFit.contain,),
                            ),
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    _photos.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.close_rounded, color: Colors.red,),

                            ),
                          ]
                        );
                      },
                    ),
                  ),

                  Container(
                    child: ( _photos.length >= 4) ? null : TextButton.icon(
                      onPressed: () async{
                        var _images = await _imagePickerService.getPhotosFromGallery();
                        if(_images!=null){
                          setState(() {
                            if(_photos.isNotEmpty){
                              for (var e in _images) {
                                _photos.add(e);
                              }
                            }else{
                              _photos = _images;
                            }
                          });
                        }
                      },
                      icon: Icon(Icons.add,color: Color(0xff707070),),
                      label: Text("ajouter des photos (maximum : 4)",style: TextStyle(color: Color(0xff707070)),),
                      style: ButtonStyle(
                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                      ),
                    ),
                  ),

                  SizedBox(height: 30,),

                  TextFormField(
                    controller: _locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      label: Text("Localisation"),
                      fillColor: Color(0xfffafafa),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.location_on),
                        onPressed: () {
                          _show();
                          },
                      ),
                    ),
                    validator: validator,
                  ),

                  SizedBox(height: 30,),



                  ElevatedButton(
                    child: Text("Ajouter la publication"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryBlue,),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      fixedSize: MaterialStateProperty.all(Size(width*0.9,50)),
                    ),
                    onPressed: ()async{
                      if (_formKey.currentState!.validate()){
                       await BackendManager.getBackendManager.addPublication(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            date: _date.toString(), category: _category,
                            latlng: _location,
                            images: _photos,
                            owner: User(firstName: "firstName", lastName: "lastName", phone: "phone", email: "email", photo : ""),
                            type: _type,
                        );
                        //Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                      }

                      },
                  ),
                ],


              ),
            ),
          ),
        )
    );
  }
}
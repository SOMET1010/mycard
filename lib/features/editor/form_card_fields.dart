/// Formulaire pour les champs essentiels de la carte
library;
import 'package:flutter/material.dart';
import 'package:mycard/core/utils/validators.dart';

class CardFieldsForm extends StatelessWidget {
  const CardFieldsForm({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.titleController,
    required this.companyController,
    required this.phoneController,
    required this.emailController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController titleController;
  final TextEditingController companyController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom complet
            TextFormField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Ex.: Bernard Kouamé',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Fonction / Titre professionnel
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Fonction / Titre professionnel',
                hintText: 'Ex.: Développeur, Directeur Marketing',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateTitle,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Entreprise / Organisation
            TextFormField(
              controller: companyController,
              decoration: const InputDecoration(
                labelText: 'Entreprise / Organisation',
                hintText: 'Ex.: Acme Inc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: Validators.validateCompany,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Numéro de téléphone et Adresse e-mail
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: 'Ex.: +225 07 12 34 56 78',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: Validators.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse e-mail',
                      hintText: 'Ex.: prenom.nom@exemple.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

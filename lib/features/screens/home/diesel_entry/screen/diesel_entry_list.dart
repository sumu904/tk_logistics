import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tk_logistics/features/screens/home/diesel_entry/screen/diesel_entry_all_list.dart';
import 'package:tk_logistics/features/screens/home/diesel_entry/screen/diesel_entry_user_list.dart';

import '../../../../../util/app_color.dart';
import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class DieselEntryList extends StatefulWidget {
  const DieselEntryList({super.key});

  @override
  State<DieselEntryList> createState() => _DieselEntryListState();
}

class _DieselEntryListState extends State<DieselEntryList>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mintGreenBG,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.neviBlue,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 22,
              color: AppColor.white,
            ),
          ),
          title: Text(
            "Diesel Entry List",
            style: quicksandBold.copyWith(
                fontSize: Dimensions.fontSizeEighteen, color: AppColor.white),
          )),
      body: Column(children: [
        // TabBar at the top
        TabBar.secondary(
          controller: _tabController,
          indicatorColor: AppColor.neviBlue,
          labelColor: AppColor.neviBlue,
          unselectedLabelColor: AppColor.grey3,
          labelStyle: quicksandBold.copyWith(
              fontSize: Dimensions.fontSizeSixteen,
              fontWeight: FontWeight.w900),
          tabs: [
            Tab(text: "User List"),
            Tab(text: "All List"),
          ],
        ),

        // TabBarView wrapped in Expanded
        Expanded(
            child: TabBarView(controller: _tabController, children: [
          DieselEntryUserList(),
          DieselEntryAllList(),
        ]))
      ]),
    );
  }
}

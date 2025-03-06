class ActionModel{

  String ?image,title;
  ActionModel({
    this.title,this.image,
  });
}

List<ActionModel> actionList=[
  ActionModel(
      image: "assets/images/create_trip.jpeg",
      title: "Create New Trip"
  ),ActionModel(
      image: "assets/images/trip_history.jpg",
      title: "Update Your Trip"
  ),
  ActionModel(
      image: "assets/images/diesel_entry.jpg",
      title: "Diesel Entry"
  ),ActionModel(
      image: "assets/images/vehicle_maintenance.jpg",
      title: "Vehicle Maintenance"
  ),
];

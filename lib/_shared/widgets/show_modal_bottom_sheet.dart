import 'package:flutter/material.dart';
import 'package:public_chat/features/chat/ui/local_background_chat_screen.dart';
import 'rounded_container.dart';

showBottomSheetExpand(BuildContext context,
    {required Widget Function(BuildContext, ScrollController, bool isMax)
        builder,
    bool showIsMax = true,
    double? initialChildSize}) {
  //tap outside to hide bottomSheet
  Widget makeDismissible({required DraggableScrollableSheet child}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        isShowBottomSheet = false;
        Navigator.pop(context);
      },
      child: GestureDetector(
        onTap: () {},
        child: child,
      ),
    );
  }

  bool isMax = false;
  showModalBottomSheet(
    useSafeArea: true,
    constraints:
        BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height), //
    //max of ctn duoi
    // Text('History',
    // style: GoogleFonts.sarabun(fontWeight: FontWeight.bold, fontSize: 20)),
    // enableDrag: false,//ko keo len xuong dc
    // isDismissible: false,//tap outside don't hide it
    isScrollControlled: true, //get to max height//compul to archive full screen
    context: context,
    builder: (context) {
      return RoundedContainer(
        child: StatefulBuilder(builder: (context, setState) {
          return makeDismissible(
            child: DraggableScrollableSheet(
                snap: true,
                expand: isMax,
                initialChildSize: isMax ? 1 : initialChildSize ?? 0.5,
                // maxChildSize: 0.5,//max of ctn tren
                // minChildSize: 0.5,//keo xuong den 1/2 man hinh thi bien mat
                builder: (context, ctrl) {
                  return Column(
                    children: [
                      if (showIsMax)
                        InkWell(
                          onTap: () {
                            setState.call(() {
                              isMax = !isMax;
                            });
                          },
                          child: Icon(
                            !isMax
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 50,
                          ),
                        ),
                      Expanded(
                        child: builder(context, ctrl, isMax),
                      )
                    ],
                  );
                }),
          );
        }),
      );
    },
  );
}

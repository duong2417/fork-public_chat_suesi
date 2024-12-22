import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:flutter_eval/widgets.dart';
import 'package:public_chat/_shared/widgets/show_modal_bottom_sheet.dart';
import 'package:public_chat/features/chat/ui/bong_bong_chat_gpt.dart';
import 'package:public_chat/features/bong_bong_chat/codebase_model.dart';
import 'package:public_chat/main.dart';
import '../../../const.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
bool isShowBottomSheet = false;

class BackgroundChatScreen extends StatelessWidget {
  const BackgroundChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream:
            firestore.collection(codebase).doc(publicChatScreen).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading messages: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading messages...'));
          }
          if (snapshot.data?.exists != true) {
            // return const Center(child: Text('No codebase...'));
            setUpCollection().then((value) {});
          }
          final model = CodebaseModel.fromJson(
              snapshot.data?.data() as Map<String, dynamic>);
          final int len = model.new_codes?.length ?? 0;
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            final PageController _pageController = PageController();
            int _currentPage = 0;
            // if (isShowBottomSheet == false) {//TODO
            showBottomSheetExpand(context,
                builder: (context, scrollController, isMax) {
              isShowBottomSheet = true;
              void _navigateToPage(int page) {
                _pageController.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }

              return StatefulBuilder(builder: (context, setState) {
                return PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    _currentPage = index;
                    setState(() {});
                  },
                  children: (model.new_codes ?? [])
                      .map(
                        (e) => Column(
                          // alignment: Alignment.topRight,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('Accept'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        firestore
                                            .collection(codebase)
                                            .doc(publicChatScreen)
                                            .update({
                                          "code": model.ori_code,
                                        });
                                      },
                                      child: const Text('Decline'),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('Edit')),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('Regenerate')),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 100,
                              child: SingleChildScrollView(
                                child: Text(e),
                              ),
                            ),
                            Row(
                              children: [
                                if (_currentPage > 0)
                                  ElevatedButton(
                                    // heroTag: 'prev',
                                    // mini: true,
                                    onPressed: () {
                                      _navigateToPage(_currentPage - 1);
                                      firestore
                                          .collection(codebase)
                                          .doc(publicChatScreen)
                                          .update({
                                        "code": model.new_codes![_currentPage],
                                      });
                                    },
                                    child: const Icon(Icons.arrow_back),
                                  ),
                                if (_currentPage < len - 1)
                                  ElevatedButton(
                                    // heroTag: 'next',
                                    // mini: true,
                                    onPressed: () {
                                      _navigateToPage(_currentPage + 1);
                                      firestore
                                          .collection(codebase)
                                          .doc(publicChatScreen)
                                          .update({
                                        "code": model.new_codes![_currentPage],
                                      });
                                    },
                                    child: const Icon(Icons.arrow_forward),
                                  ),
                              ],
                            )
                          ],
                        ),
                      )
                      .toList(),
                );
              });
            });
            // }
          });
          return CompilerWidget(
            packages: {
              model.folder_name: {
                model.file_name: model.code ??
                    '''import 'package:flutter/material.dart';
class BaseScreen extends StatelessWidget {
  const BaseScreen(this.widget);
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: widget,
      ),
    );
  }
}'''
              }
            },
            library: 'package:${model.path}',
            function: '${model.class_name}.',
            args: [$Widget.wrap(const MyPublicChatScreen())],
          );
        });
  }
}

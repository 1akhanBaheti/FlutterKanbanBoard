import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kanban_board/src/constants/scroll_config_constants.dart';
import 'package:kanban_board/src/controllers/states/scroll_state.dart';

class PlatformScrollConfiguration {
  static GroupScrollConfig get groupScrollConfig {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return const GroupScrollConfig(
        curve: Curves.linear,
        farBoundary: Boundary(
          boundary: DesktopScrollConfigConstants.GROUP_FAR_SCROLL_BOUNDARY,
          offset: DesktopScrollConfigConstants.GROUP_FAR_SCROLL_MOVE,
          duration: DesktopScrollConfigConstants.GROUP_FAR_SCROLL_DURATION,
        ),
        midBoundary: Boundary(
          boundary: DesktopScrollConfigConstants.GROUP_MID_SCROLL_BOUNDARY,
          offset: DesktopScrollConfigConstants.GROUP_MID_SCROLL_MOVE,
          duration: DesktopScrollConfigConstants.GROUP_MID_SCROLL_DURATION,
        ),
        nearBoundary: Boundary(
          boundary: DesktopScrollConfigConstants.GROUP_NEAR_SCROLL_BOUNDARY,
          offset: DesktopScrollConfigConstants.GROUP_NEAR_SCROLL_MOVE,
          duration: DesktopScrollConfigConstants.GROUP_NEAR_SCROLL_DURATION,
        ),
      );
    }
    return const GroupScrollConfig(
      curve: Curves.linear,
      farBoundary: Boundary(
        boundary: MobileScrollConfigConstants.GROUP_FAR_SCROLL_BOUNDARY,
        offset: MobileScrollConfigConstants.GROUP_FAR_SCROLL_MOVE,
        duration: MobileScrollConfigConstants.GROUP_FAR_SCROLL_DURATION,
      ),
      midBoundary: Boundary(
        boundary: MobileScrollConfigConstants.GROUP_MID_SCROLL_BOUNDARY,
        offset: MobileScrollConfigConstants.GROUP_MID_SCROLL_MOVE,
        duration: MobileScrollConfigConstants.GROUP_MID_SCROLL_DURATION,
      ),
      nearBoundary: Boundary(
        boundary: MobileScrollConfigConstants.GROUP_NEAR_SCROLL_BOUNDARY,
        offset: MobileScrollConfigConstants.GROUP_NEAR_SCROLL_MOVE,
        duration: MobileScrollConfigConstants.GROUP_NEAR_SCROLL_DURATION,
      ),
    );
  }

  static BoardScrollConfig get boardScrollConfig {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      return const BoardScrollConfig(
        curve: Curves.linear,
        farBoundary: Boundary(
          boundary: DesktopScrollConfigConstants.BOARD_FAR_SCROLL_BOUNDARY,
          offset: DesktopScrollConfigConstants.BOARD_FAR_SCROLL_MOVE,
          duration: DesktopScrollConfigConstants.BOARD_FAR_SCROLL_DURATION,
        ),
        midBoundary: Boundary(
          boundary: DesktopScrollConfigConstants.BOARD_MID_SCROLL_BOUNDARY,
          offset: DesktopScrollConfigConstants.BOARD_MID_SCROLL_MOVE,
          duration: DesktopScrollConfigConstants.BOARD_MID_SCROLL_DURATION,
        ),
        nearBoundary: Boundary(
          boundary: DesktopScrollConfigConstants.BOARD_NEAR_SCROLL_BOUNDARY,
          offset: DesktopScrollConfigConstants.BOARD_NEAR_SCROLL_MOVE,
          duration: DesktopScrollConfigConstants.BOARD_NEAR_SCROLL_DURATION,
        ),
      );
    }
    return const BoardScrollConfig(
      curve: Curves.linear,
      farBoundary: Boundary(
        boundary: MobileScrollConfigConstants.BOARD_FAR_SCROLL_BOUNDARY,
        offset: MobileScrollConfigConstants.BOARD_FAR_SCROLL_MOVE,
        duration: MobileScrollConfigConstants.BOARD_FAR_SCROLL_DURATION,
      ),
      midBoundary: Boundary(
        boundary: MobileScrollConfigConstants.BOARD_MID_SCROLL_BOUNDARY,
        offset: MobileScrollConfigConstants.BOARD_MID_SCROLL_MOVE,
        duration: MobileScrollConfigConstants.BOARD_MID_SCROLL_DURATION,
      ),
      nearBoundary: Boundary(
        boundary: MobileScrollConfigConstants.BOARD_NEAR_SCROLL_BOUNDARY,
        offset: MobileScrollConfigConstants.BOARD_NEAR_SCROLL_MOVE,
        duration: MobileScrollConfigConstants.BOARD_NEAR_SCROLL_DURATION,
      ),
    );
  }
}

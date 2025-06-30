cmake_minimum_required(VERSION 3.16)

project(AmericanMusic VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS 
    Quick 
    Qml 
    Widgets 
    QuickControls2 
    Svg 
REQUIRED)

set(ZLIB_ROOT "D:/vcpkg/vcpkg/installed/x64-windows" CACHE PATH "")
find_package(ZLIB REQUIRED)
    
    

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appAmericanMusic
    main.cpp
)

qt_add_qml_module(appAmericanMusic
    URI AmericanMusic
    VERSION 1.0
    QML_FILES
        Main.qml
        RESOURCES src.qrc
        RESOURCES qml.qrc
        QML_FILES RightPage/RightPage.qml
        QML_FILES LeftPage/LeftPage.qml
        QML_FILES LeftPage/Utils/IconProvider.qml
        SOURCES pathutils.h pathutils.cpp
        QML_FILES CustomUI/TokyoButton.qml
        QML_FILES src/title/Title.qml
        QML_FILES BottomBar/BottomBar.qml
        QML_FILES RightPage/TitleBar/TitleBar.qml
        QML_FILES RightPage/StackPages/MusicCherryPick.qml
        QML_FILES RightPage/StackPages/CherryPick.qml
        QML_FILES RightPage/StackPages/CarouselImage.qml
        QML_FILES RectTest.qml
        QML_FILES RightPage/StackPages/CarouselSlide.qml
        QML_FILES RightPage/StackPages/OfficialMusic.qml
        QML_FILES RightPage/StackPages/RecentMusic.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appAmericanMusic PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appAmericanMusic
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    # WIN32_EXECUTABLE TRUE
)

target_link_libraries(appAmericanMusic
    PRIVATE 
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg 
    Qt6::Qml
    ZLIB::ZLIB  # 显式链接ZLIB

)

include(GNUInstallDirs)
install(TARGETS appAmericanMusic
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Private 1.0

/*!
    \qmltype CalendarStyle
    \inqmlmodule QtQuick.Controls.Styles
    \since QtQuick.Controls.Styles 1.1
    \ingroup controlsstyling
    \brief Provides custom styling for \l Calendar

    Example:
    \qml
    Calendar {
        anchors.centerIn: parent

        style: CalendarStyle {
            dateDelegate: Rectangle {
                readonly property bool thisMonth: cellDate.getMonth() === control.selectedDate.getMonth()

                gradient: Gradient {
                    GradientStop {
                        position: 0.00
                        color: isCurrentItem ? "#111" : (thisMonth ? "#444" : "#666");
                    }
                    GradientStop {
                        position: 1.00
                        color: isCurrentItem ? "#444" : (thisMonth ? "#111" : "#666");
                    }
                    GradientStop {
                        position: 1.00
                        color: isCurrentItem ? "#777" : (thisMonth ? "#111" : "#666");
                    }
                }

                Text {
                    text: cellDate.getDate()
                    anchors.centerIn: parent
                    color: "white"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#555"
                    anchors.bottom: parent.bottom
                }

                Rectangle {
                    width: 1
                    height: parent.height
                    color: "#555"
                    anchors.right: parent.right
                }
            }
        }
    }
    \endqml
*/

Style {
    id: calendarStyle

    /*!
        The number of weeks to be shown.
    */
    readonly property int weeksToShow: 6

    /*!
        The height of the navigation bar.
    */
    readonly property real navigationBarHeight: 40

    /*!
        The width of each cell in the view.
    */
    readonly property real cellWidth: control.width % 2 == 0
        ? control.width / DateUtils.daysInAWeek
        : Math.floor(control.width / DateUtils.daysInAWeek)

    /*!
        The height of each cell in the view.
    */
    readonly property real cellHeight: {control.height - navigationBarHeight % 2 == 0
        ? (parent.height - navigationBarHeight) / (weeksToShow + 1)
        : Math.floor((control.height - navigationBarHeight) / (weeksToShow + 1))
    }

    /*!
        The Calendar attached to this style.
    */
    property Calendar control: __control

    /*!
        The background of the calendar.

        This component is typically not visible (that is, it is not able to be
        seen; the \l {Item::visible}{visible} property is still \c true) if the
        other components are fully opaque and consume as much space as possible.
    */
    property Component background: Rectangle {
        color: "#fff"
    }

    /*!
        The navigation bar of the calendar.

        Styles the bar at the top of the calendar that contains the
        next month/previous month buttons and the selected date label.
    */
    property Component navigationBar: Item {
        visible: control.navigationBarVisible
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#464646"
        }

        KeyNavigation.tab: previousMonth

        Button {
            id: previousMonth
            width: parent.height * 0.6
            height: width
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: (parent.height - height) / 2
            iconSource: "images/arrow-left.png"

            onClicked: control.previousMonth()
        }
        Text {
            id: dateText
            text: control.selectedDateText
            color: "#fff"

            font.pixelSize: 12
            anchors.centerIn: parent
        }
        Button {
            id: nextMonth
            width: parent.height * 0.6
            height: width
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: (parent.height - height) / 2
            iconSource: "images/arrow-right.png"

//            KeyNavigation.tab: control.view

            onClicked: control.nextMonth()
        }
    }

    /*!
        The delegate that styles each date in the calendar.

        The properties provided by the view to each delegate are:
        \list
            \li property date cellDate
            \li readonly property bool isCurrentItem
        \endlist
    */
    property Component dateDelegate: Rectangle {
        id: dayDelegate
        color: cellDate !== undefined && isCurrentItem ? selectedDateColor : "white"
//        radius: 1
        readonly property color sameMonthDateTextColor: "black"
        readonly property color selectedDateColor: "steelblue"
        readonly property color selectedDateTextColor: "white"
        readonly property color differentMonthDateTextColor: Qt.darker("darkgrey", 1.4);
        readonly property color invalidDatecolor: "#dddddd"

        Text {
            id: dayDelegateText
            text: cellDate.getDate()
            font.pixelSize: 14
            anchors.centerIn: parent
            color: {
                var color = invalidDatecolor;
                if (control.isValidDate(cellDate)) {
                    // Date is within the valid range.
                    color = cellDate.getMonth() === control.selectedDate.getMonth()
                        ? sameMonthDateTextColor : differentMonthDateTextColor;

                    if (GridView.isCurrentItem) {
                        color = selectedDateTextColor
                    }
                }
                color;
            }
        }
    }

    /*!
        The delegate that styles the header of the calendar.
    */
    property Component headerDelegate: Row {
        id: headerRow
        Repeater {
            id: repeater
            model: CalendarHeaderModel { locale: control.locale }
            Item {
                width: calendarStyle.cellWidth
                height: calendarStyle.cellHeight
                Rectangle {
                    color: "white"
                    anchors.fill: parent
                    Text {
                        text: DateUtils.dayNameFromDayOfWeek(control.locale,
                            control.dayOfWeekFormat, dayOfWeek)
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    /*! \internal */
    property Component panel: Item {
        anchors.fill: parent
        implicitWidth: 250
        implicitHeight: 250

        property alias navigationBarItem: navigationBarLoader.item

        Loader {
            id: backgroundLoader
            anchors.fill: parent
            sourceComponent: background
        }

        Loader {
            id: navigationBarLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: calendarStyle.navigationBarHeight
            sourceComponent: navigationBar
        }
    }
}
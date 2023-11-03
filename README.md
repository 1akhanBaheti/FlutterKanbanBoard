# Flutter KanbanBoard
It is a customizable kanban board, which can be used to reorder items and list with drag and drop.

## Installation
Just add ``` kanban_board ``` to the ``` pubspec.yaml ``` file.

## Usage Example

To get started you can look inside the ``` /example``` folder. This package is broken into 3 core parts

![Example](https://raw.githubusercontent.com/1akhanBaheti/FlutterKanbanBoard/demo-gif/gif/kanban_board_neo.gif)


### KanbanBoard

The KanbanBoard class takes in a List of BoardListsData

``` dart

List<BoardListsData> _lists = List<BoardListsData>();

KanbanBoard(
   _lists,
);

```
It can take some other parameters also like :
```

BackgroundColor,
CardPlaceHolderColor,
ListPlaceHolderColor,
BoardDecoration,
CardTransitionBuilder,
ListTransitionBuilder,
CardTransitionDuration,
ListTransitionDuration,
ListDecoration,
TextStyle,
DisplacementX = 0.0,
DisplacementY = 0.0,

```

### Callbacks

The Kanban Board has several callback methods that get called when dragging. A long press on the item field widget will begin the drag process.

``` dart
KanbanBoard(

onItemLongPress: (int cardIndex,int listIndex) { },
    
onItemReorder: (int oldCardIndex, int newCardIndex, int oldListIndex, int newListIndex) { },
        
onListLongPress: (int listIndex) { },
        
onListReorder: (int oldListIndex, int newListIndex) {},
        
onItemTap: (int cardIndex, int listIndex){},

onListTap: (int listIndex){}

);
```
### BoardListsData

The BoardListData has several parameters to customize lists in board. The header & footer expects a Widget as its object, and items expect List<Widget>. The header item on long press will begin the drag process for the BoardList.

``` dart

    BoardListsData(
      title: 'TITLE',
      width: 300,
      headerBackgroundColor: Color.fromARGB(255, 235, 236, 240),
      footerBackgroundColor: Color.fromARGB(255, 235, 236, 240),
      backgroundColor: Color.fromARGB(255, 235, 236, 240),
      header: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  "List Title",
                  style: TextStyle(fontSize: 20),
                )),

      footer :Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  "List Footer",
                  style: TextStyle(fontSize: 20),
                )),   
      items: items,
    );

```

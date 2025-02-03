# **INFO1113 WizardTD Game Report**

#### **SID:** 530536402     **Author:** Yilin Li

## <u>**Object-Oriented Design Decisions**</u>

### **1. Brief Overview**

In the `WizardTD` game design, I have judiciously adopted an object-oriented approach to streamline and compartmentalize various functionalities, ensuring both modularity and clarity.

#### **Class Features**

- ##### `Buttons` class

  This class serves as the game's user interface's base, representing interacting elements. It records critical information such as position, dimensions, and labels, allowing for user interactions and supporting tasks such as tower placements or gameplay controls.

- ##### `Monsters` class

  The 'Monsters' class is crucial to the game's challenge and dynamics, representing the enemies that players must defeat. We encapsulate properties such as health, speed, and pathfinding logic, as well as methods for movement and interactions with towers, in this class.

- ##### `Tower` class

  The 'Tower' class represents constructions that may be constructed within the game area and serves as the player's primary defence mechanism. 

- ##### `Background (inside App)` class

  The 'App' class is a container for the game's overall environment and mechanics. While the core classes specify individual entities, the term 'App' refers to the overall game state, which includes the background design, public lists used across several classes, game loop control, and other overarching functionalities.

By segregating the game's functionalities into these distinct classes, we not only enhance code manageability but also lay a robust foundation for potential future expansions or modifications.

### **2. Inheritance**

#### **Buttons inheritance**

The object-oriented idea of inheritance is cleverly used in the WizardTD game to construct a hierarchical relationship between buttons. 

In my program, the Buttons class is extended by the TowerButton class, which inherits its main attributes and methods. As a result, a TowerButton is effectively a subset of Buttons. What distinguishes TowerButton is its additional functionality designed exclusively for manipulating tower placements within the game. 

The design ensures a modular and scalable architecture by exploiting inheritance. The base Buttons class abstracts common button capabilities, providing code reusability, while specialised behaviours are introduced in the subclasses, fostering a clear and organised structure.







# **WizardTD UML**

The above figure depicts the UML (Unified Modelling Language) representation of the WizardTD game's structure, emphasising the relationships, properties, and methods of the game's core classes.

![Assignment_UML](/Users/y2l/Downloads/Assignment_UML.png)
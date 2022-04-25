# Lesson 2 Notes #

Everything truthy _except for_ nil and false

## Pseudo Code ##

We don't use programming code first, because we're trying to load the problem
into our brain first.

There are two layers to solving any problem:
  1. The logical problem domain layer
  2. The syntactical programming language layer

### Formal Psuedocode ###

| keyword             | meaning                              |
| -------             | -------                              |
| START               | start of the program                 |
| SET                 | sets a variable we can use for later |
| GET                 | retrieve input from user             |
| PRINT               | displays output to user              |
| READ                | retrieve value from variable         |
| IF / ELSE IF / ELSE | show conditional branches in logic   |
| WHILE               | show looping logic                   |
| END                 | end of the program                   |
| SUBPROCESS          | some other _thing_ that will execute |

[[plain english pseudocode]]
[[pseudocode using keywords]]

---

_IMPERATIVE_ or _PROCEDURAL_ problem solving
  - Use a flowchart to specifically draw out the iteration logic
  - Explicit step-by-step logic to solve a problem
  - Lower level approach, closer to how computer thinks

_DECLARATIVE_ problem solving
  - Use methods like .each()
  - Higher level approach, abstracts some steps
  - When used in flowchart or pseudocode, can help restrict scope

---

## Debugging ##

Strive to develop a systematic, logical, and patient temperament when
confronted with tricky bugs

Dealing with feelings of frustration is the first critical aspect of learning to program.

### Error Messages ###

A _stack trace_ is a heirarchical trace of the function calls made by a program,
used in debugging.

#### Online Resources for Interpreting Error Messages ####

- Search Engine
  - Don't include search terms specific to your program
  - Add search terms that could help narrow results, i.e. add "Ruby" if
    debugging a Ruby program
- Stack Overflow
  - Often highly ranked in search results, but could be worth searching directly
- Documentation

### Steps to Debugging ###

1. Reproduce the Error
2. Determine the Boundaries of the Error
3. Trace the Code
4. Understand the Problem Well
5. Implement a Fix
6. Test the Fix

### Techniques for Debugging ###

1. Line by Line
  - Be patient, most bugs come from overlooking a small detail
2. Rubber Duck
  - Use an object as a sounding board
  - When forced to explain the problem, often the root will be exposed
3. Walking Away
4. Using Pry
  - For Ruby, or equivalent for other languages.
5. Using a Debugger

---

## Precedence ##

https://docs.ruby-lang.org/en/3.0.0/doc/syntax/precedence_rdoc.html

---

### Unary and Ternary Operators ###
2 + 5             # Two operands (2 and 5)
!true             # Unary: One operand (true)
value ? 1 : 2     # Ternary: Three operands (value, 1, 2)

---
Parentheses override the default evaluation order

_USE PARENTHESES_

An operator that has higher precedence than another is said to _bind_ more
tightly to its operands.

---

### Ruby's tap Method ###

```
mapped_array = array.map { |num| num + 1 }

mapped_array.tap { |value| p value } # => [2, 3, 4]
```

It simply passes the calling object into a block, then returns that object.

---

## Coding Tips

* Dramatic experiences help retain knowledge
  * Hours spent debugging an issue will 'burn' it into your memory
  * Learn to embrace debugging simple issues, it is increasing your skill
   
* Name variables after the _INTENT_ of the variable, not a possible response
  value or how they are set
 
* Ruby is flexible and will allow for creation of variables with different
  capitalization, but _follow convention_:
 
  * snake_case for everything but classes (CamelCase) or constants (UPPERCASE)
   
* Use Rubocop!

* Don't mutate CONSTANTS, even though ruby will let you

* Making your code **readable** is super important for yourself and others
  
  * New lines help to make code more readable

* Never use assignment in a conditional

  * It can work, but it is ambiguous
  * If it must be done, wrap the assignment in parentheses

### Methods

* Keep methods short, and have them do _one thing_
  * 10 lines or less is best

* Don't display something to the output and return a *meaningful* value.

* Understand if a method returns a value, has a side effect, or both
 
* Return a value with no side effects *or* perform side effects w/ no return.
  * Reflect this intent of the method in its name

* Keep methods on the same level of abstraction
  * Should be able to work with them in isolation
  * Method names should say *WHAT* they do, not *HOW*
  * Method names should reflect mutation

* If a method is hard to understand that could be because of a lack of
  understanding of the problem

* Name methods appropriately, so that the reason for the method is clear

  * If you find yourself looking at the implementation every time you use a
    method, it's a sign the method needs to be improved
  
  * If you can treat a method as a 'black box', it's well designed

* Don't mutate callers during iteration

  * Elements can be mutated, but not the collection itself

---

## Variable Scope

* Blocks create a new scope for local variables called an _inner scope_
 
* Variables initialized in an outer scope can be accessed in an inner scope, but
  not vice versa
 
* Variables can be changed from within an inner scope, and these changes will be
  reflected in the outer scope

* Another reason to be careful to avoid single letter names, and be as
  descriptive as possible when naming variables

### Nested Blocks

* Just like regular scoping, lower levels can access higher levels but not vice
  versa

### Variable Shadowing

* Shadowed variables in an inner scope prevent access to the outer scope
  variable.
 
* Avoid by using longer, more descriptive variable names

### Variables and Method Definitions

* Method definitions have isolated scopes, all parameters must be explicitly
  passed into or intialized within the definition

* Local variables and methods can have exact same names (not advised). Ruby will
  prioritize local variables over methods. To specify the method, empty argument
  parentheses can be used.

### Constants

* In procedural style programming, constants behave like global variables (can
  be accessed anywhere)
  
* Constants possess _lexical scope_

## More Variable Scope

### Method Definition

When a Ruby method is defined using the 'def' keyword

```
def greeting
  puts 'Hello'
end
```

### Method Invocation

When a Ruby method is called, with or without a block or parameters

```
greeting
```

* When a method is called with a block, that block acts as an argument to the
  method

* A parameter doesn't have to be used within a method, even if it is passed

* A block will not be used if passed to a method, unless the method definition
  accounts for it.
  
* Methods can use the return value of a block passed to them

* A method _definition_ can't acceess or reassign local variables initialized in
  an outside scope, but a _block_ can do so

* A method definition sets a certain scope for local variables, and a method
  invocation uses that scope. 
  
* Blocks can provide extra flexibility in how the method invocation can interact
  with its surroundings

## Pass by Reference vs. Pass by Value

### Passing by Value

* When you "pass by value", the method only has a _copy_ of the original object.
  Operations performed on the object within the method have no effect on the
  original object outside of the method.

* Ruby is in many cases pass by value, because reassigning the object within the
  method doesn't affect the object outside of the method.
  
### Passing by Reference

* Ruby methods can in fact change object which have been passed as arguments,
  for example:
  
  ```
  def cap(str)
    str.capitalize! # does this affect the object outside the method?
  end
  
  name = 'jim'
  cap(name)
  puts name         # => Jim
  ```
* If Ruby were pass by value, the method should not be able to change the object

* Pass by reference is like a pointer

### What Ruby does

* Ruby can pass by reference or value, called _pass by value of the reference_
  or _call by sharing_. 
    
   **When an operation within the method mutates the caller, it will affect the original object**
    
* Specific methods mutate arrays

* Reassignment is not destructive

### Variables as Pointers

* Variables **point** to addresses in memory

* Assignment (=) will point the variable to a different address in memory, a
  new object

* A method which mutates the caller will change the object that the variable
  points to, isntead of pointing it to a new object

* Variables referencing objects can be described as **bonding** to them

* Every object in Ruby has a unique **object id** 

### Mutability

* Mutable objects have values which can be altered, immutable objects can only
  be reassigned
  
* In ruby **numbers and booleans** are immutable. 

* Most other objects are mutable:
  * They are usually mutated via **setter methods**, such as `Array#[]=`
  
* Many, _but not all_, methods that mutate their caller use ! as the last
  character of their name.

* Indexed assignment (String, Hash, and Array objects) is mutating

### Object Passing

* When a method is called with some expression as an argument, that expression
  is evaluated and reduced to an object, which is then made available inside of
  that method

* Object _callers_ can be thought of as an implied argument

* Many operators such as +, *, [] and ! are methods, which means their operands
  are arguments.

* Ruby's variables don't contain values, they are always references to objects
  
  * Even if a literal is passed to a method, ruby will create an internal
    reference to that object.
    
    * This is called an **anonymous reference**
  
  * Ruby can be described as being **pass by reference value** or 
    **pass by value of the reference**
   
#### Evaluation Strategies

* The most common evaluation strategies are called **strict evaluation**
  strategies.
  
  * Every expression is evaluated and converted to an object before it is passed
    to a method
  
  * Ruby exclusively uses strict evaluation strategies
  
  * Pass by value and pass by reference are both strict evaluation strategies
  
    * Ruby uses a third strategy which blends these two
  
  * Ruby appears to pass by value when passing immutable objects, and appears to
    pass by reference when passing mutable objects

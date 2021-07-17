Rosetta Modelling Components
============================
**The Rosetta syntax can express eight types of model components**:

* Data
* Meta-Data
* Expression (or *logic*)
* Data Validation (or *condition*)
* Function
* Namespace
* Mapping (or *synonym*)
* Reporting

This documentation details the purpose and features of each type of model component and highlights the relationships that exist among those. As the initial live application of the Rosetta DSL, examples from the ISDA CDM will be used to illustrate each of those features.


.. _data-component-label:

Data Component
--------------
**The Rosetta DSL provides two data definition components** that are used to model data:

* `Type <#type-label>`_
* `Enumeration <#enumeration-label>`_

.. _type-label:

Type
^^^^
Purpose
"""""""
A *type* describes an *entity* (also sometimes referred to as an *object* or a *class*) in the model and is defined by a plain-text description and a set of *attributes* (also sometimes referred to as fields). Attributes specify the granular elements composing the entity.

Syntax
""""""
The definition of a type starts with the keyword ``type``, followed by the type name. A colon ``:`` punctuation introduces the rest of the definition.

The Rosetta DSL convention is that type names use the *PascalCase* (starting with a capital letter, also referred to as the *upper* `CamelCase`_). Type names need to be unique across a `namespace <#namespace-label>`_. All those requirements are controlled by the Rosetta DSL grammar.

The first component of the definition is a plain-text description of the type.

After the description come any further `meta-data annotations <#meta-data-component-label>`_ that are applied to this type. Meta-data are enclosed within square brackets ``[...]``.

.. code-block:: Haskell
 
  type WorkflowStep: <"A workflow step ....">
   [metadata key]
   [rootType]

Then the definition of the type lists its component attributes. Each attribute is defined by three required components, and two optional components, syntactically ordered as:

* name - 
  Required - Attribute names use the *camelCase* (starting with a lower case letter, also referred to as the *lower* camelCase).
* type - 
  Required - Each attribute can be specified either as a `basic type <#basic-type-label>`_, `record type <#record-type-label>`_, data type or `enumeration type <#enumeration-label>`_.
* cardinality -  
  Required - see `Cardinality <#cardinality-label>`_
* description - Optional but recommended) - A description of the attribute using the same <"..."> syntax as the type description
* annotations - Optional - Annotations such as `synonyms <mapping.html>`_ or metadata can be applied to attributes

.. code-block:: Haskell

  type PeriodBound: <"The period bound is defined as a period and whether the bound is inclusive.">
    period Period (1..1) <"The period to be used as the bound, e.g. 5Y.">
    inclusive boolean (1..1) <"Whether the period bound is inclusive, e.g. for a lower bound, false would indicate greater than, whereas true would indicate greater than or equal to.">

 type Period: <"A class to define recurring periods or time offsets.">
   periodMultiplier int (1..1) <"A time period multiplier, e.g. 1, 2 or 3 etc. A negative value can be used when specifying an offset relative to another date, e.g. -2 days.">
   period PeriodEnum (1..1) <"A time period, e.g. a day, week, month or year of the stream. If the periodMultiplier value is 0 (zero) then period must contain the value D (day).">

.. note:: The Rosetta DSL does not use any delimiter to end definitions. All model definitions start with a similar opening keyword as ``type``, so the start of a new definition marks the end of the previous one. For readability more generally, the Rosetta DSL looks to eliminate all the delimiters that are often used in traditional programming languages (such as curly braces ``{`` ``}`` or semi-colon ``;``).

Built in types
^^^^^^^^^^^^^^
.. _basic-type-label:

Basic Types
"""""""""""
Rosetta defines five fundamental data types.  The set of basic types available in the Rosetta DSL are controlled at the language level by the ``basicType`` definition:

* ``string`` - Text
* ``int`` - integer numbers
* ``number`` - decimal numbers
* ``boolean`` - logical true of false
* ``time`` - simple time values (e.g. "05:00:00")

.. _record-type-label:

Record Types
""""""""""""
Rosetta defines two record types ``date`` and ``zonedDateTime``.  The set of record types available in the Rosetta DSL are controlled at the language level by the ``recordType`` definition.

Record types are simplified data types:

* Record types are pure data definitions and do not allow specification of validation logic in ``conditions``.
* Record types are handled specially in the code-generators as so form part of the Rosetta DSL, rather than any Rosetta base domain model. 

Time
""""
The ``zonedDateTime`` record type unambiguously refers to a single instant of time.

Alternatively in the CDM there is the data type ``BusinessCenterTime`` , where a simple ``time`` "5:00:00" is specified alongside a business centre.  The simple time should be interpreted with the time-zone information of the associated business centre.

Inheritance
"""""""""""

**The Rosetta DSL supports an inheritance mechanism**, when a type inherits its definition and behaviour (and therefore all of its attributes) from another type and adds its own set of attributes on top. Inheritance is supported by the ``extends`` keyword next to the type name.

.. code-block:: Haskell

 type Offset extends Period:
    dayType DayTypeEnum (0..1)

.. note:: For clarity purposes, the documentation snippets omit the synonyms and definitions that are associated with the classes and attributes, unless the purpose of the snippet is to highlight some of those features.

.. _enumeration-label:

Enumeration
^^^^^^^^^^^
Purpose
"""""""
**Enumeration is the mechanism through which an attribute may only take some specific controlled values**. An *enumeration* is the container for the corresponding set of controlled (or enumeration) values.

This mimics the *scheme* concept, whose values may be specified as part of an existing standard and can be represented through an enumeration in the Rosetta DSL. Typically, a scheme with no defined values is represented as a basic ``string`` type.

Syntax
""""""
Enumerations are very simple modelling containers, which are defined in the same way as other model components. The definition of an enumeration starts with the ``enum`` keyword, followed by the enumeration name. A colon ``:`` punctuation introduces the rest of the definition, which contains a plain-text description of the enumeration and the list of enumeration values.

.. code-block:: Haskell

 enum PeriodEnum: <"The enumerated values to specify the period, e.g. day, week.">
   D <"Day">
   W <"Week">
   M <"Month">
   Y <"Year">

Enumeration names must be unique across a `namespace <#namespace-label>`_. The Rosetta DSL naming convention is the same as for types and must use the upper CamelCase (PascalCase).  In addition the enumeration name should end with the suffix Enum. 
The Enumeration values cannot start with a numerical digit, and the only special character that can be associated with them is the underscore ``_``.

In order to handle the integration of scheme values which can have special characters, the Rosetta DSL allows to associate a **display name** to any enumeration value. For those enumeration values, special characters are replaced with ``_`` while the ``displayName`` entry corresponds to the actual value.

An example is the day count fraction scheme for interest rate calculation, which includes values such as ``ACT/365.FIXED`` and ``30/360``. These are associated as ``displayName`` to the ``ACT_365_FIXED`` and ``_30_360`` enumeration values, respectively.

.. code-block:: Haskell

 enum DayCountFractionEnum:
   ACT_360 displayName "ACT/360"
   ACT_365L displayName "ACT/365L"
   ACT_365_FIXED displayName "ACT/365.FIXED"
   ACT_ACT_AFB displayName "ACT/ACT.AFB"
   ACT_ACT_ICMA displayName "ACT/ACT.ICMA"
   ACT_ACT_ISDA displayName "ACT/ACT.ISDA"
   ACT_ACT_ISMA displayName "ACT/ACT.ISMA"
   BUS_252 displayName "BUS/252"
   _1_1 displayName "1/1"
   _30E_360 displayName "30E/360"
   _30E_360_ISDA displayName "30E/360.ISDA"
   _30_360 displayName "30/360"

.. _meta-data-component-label:

Meta-Data Component
-------------------

Meta-data are key parts of the syntax allowing rich definitions to all model components including the `data <#data-component-label>`_, `reporting <#reporting-component-label>`_ and `function <#function-label>`_  components. 

Descriptions
^^^^^^^^^^^^

Purpose
"""""""

Plain-text descriptions can be associated to any model component. Although not generating any executable code, descriptions are first-class meta-data components of any model. As modelling best practice, a description ought to exist for every model component and be clear and comprehensive.

Syntax
""""""

The syntax to add a description uses quotation marks in between angle brackets ``<"...">``. There are several examples throughout this document.

Document Reference
^^^^^^^^^^^^^^^^^^

Purpose
"""""""

A document reference is a type of meta-data description that can associate information published in a separate document to model components. The Rosetta DSL allows to define those specific documents, who owns them and their content as direct model components, and to associate them to any other `data <#data-component-label>`_ or `function <#function-label>`_ components.

.. _document-reference-hierarchy-label:

Syntax (Document Hierarchy)
"""""""""""""""""""""""""""

There are 3 syntax components to define the hierarchy of document references:

#. Body
#. Corpus
#. Segment

A body refers to an entity that is the author, publisher or owner of a document. Examples of bodies include regulatory authorities or trade associations.

The syntax to define a body is: ``body`` <Type> <Name> <Description>. Some examples of bodies, with their corresponding types, are given below.

.. code-block:: Haskell

 body Organisation ISDA
   <"Since 1985, the International Swaps and Derivatives Association has worked to make the global derivatives markets safer and more efficient">

 body Authority ESMA
   <"ESMA is an independent EU Authority that contributes to safeguarding the stability of the European Union's financial system by enhancing the protection of investors and promoting stable and orderly financial markets.">

 body Authority MAS
   <"The Monetary Authority of Singapore (MAS) is Singapore’s central bank and integrated financial regulator. MAS also works with the financial industry to develop Singapore as a dynamic international financial centre.">

A corpus refers to a document set that contains the textual provision that is being referenced. For example, regulatory rules can be specified according to different levels of detail, including laws (as voted by lawmakers), regulatory texts and technical standards (as published by regulators), or best practice and guidance (as published by trade associations).

The syntax to define a corpus is: ``corpus`` <Type> <Body> <Alias> <Name> <Description>. While the name of a corpus provides a mechanism to refer to such corpus as a model component in other parts of a model, an alias provides an alternative identifier by which a given corpus may be known.

Some examples of corpuses, with their corresponding types, are given below. In those cases, the aliases refer to the official numbering of document by the relevant authority.

.. code-block:: Haskell

 corpus Regulation ESMA "600/2014" MiFIR
   <"Regulation (EU) No 600/2014 of the European Parliament and of the Council of 15 May 2014 on markets in financial instruments and amending Regulation (EU) No 648/2012 Text with EEA relevance">

 corpus Act MAS "289" SFA
   <"The Securities And Futures Act relates to the regulation of activities and institutions in the securities and derivatives industry, including leveraged foreign exchange trading, of financial benchmarks and of clearing facilities, and for matters connected therewith.">

Corpuses are typically large sets of documents which can contain many rule specifications. The Rosetta DSL provides the concept of segment to allow to refer to a specific section in a given document.

The syntax to define a segment is: ``segment`` <Type>. Below are some examples of segment types, as are often found in trade association and regulatory texts.

.. code-block:: Haskell

 segment article
 segment whereas
 segment annex
 segment table
 segment namingConvention

Once a segment type is defined, it can be associated to an identifier (i.e some free text representing either the segment number or name) and combined with other segment types to point to a specific section in a document. For instance:

.. code-block:: Haskell

 article "26" paragraph "2"

.. _document-reference-label:

Syntax (Document Reference)
"""""""""""""""""""""""""""

A document reference is created using the ``docReference`` syntax. This ``docReference`` must be associated to a ``corpus`` and ``segment`` defined according to the `document reference hierarchy <#document-reference-hierarchy-label>`_ section. The document reference can copy the actual text being referred to using the ``provision`` syntax. 

.. code-block:: Haskell

    [docReference <Body> <Corpus>
      <Segment1>
      <Segment2>
      <SegmentN...>
      provision <"ProvisionText">]


In some instances, a model type may have a different naming convention based on the context in which it is being used, for example a legal definition may refer to the data type with a different name. The ``docReference`` syntax allows a type to be annotated using the naming convention ``segment`` with the ``body`` and ``corpus`` that define it.

.. code-block:: Haskell

 type PayerReceiver: <"Specifies the parties responsible for making and receiving payments defined by this structure.">
      [docReference ICMA GMRA
        namingConvention "seller" 
        provision "As defined in the GRMA Seller party ..."]

A ``docReference`` can also be added to an attribute of a type:

.. code-block:: Haskell

 type PayerReceiver: <"Specifies the parties responsible for making and receiving payments defined by this structure.">
      ...
      payer CounterpartyRoleEnum (1..1)
        [docReference ICMA GMRA
          namingConvention "seller" 
          provision "As defined in the GRMA Seller party ..."]

.. _annotation-label:

Annotation
^^^^^^^^^^
Purpose
"""""""
Annotations are a mechanism that allow additional meta-data components to be to specified in a model (beyond the ones already provided by the Rosetta DSL, such as decriptions or documemnt references). Those meta-data components can be then associated to model components to serve a number of purposes:

* to add constraints to a model that may be enforced by syntax validation
* to modify the actual behaviour of a model in generated code
* purely syntactic, to provide additional guidance when navigating model components

Examples of annotations and their usage for different purposes are illustrated below.

Syntax
""""""
Annotations are defined in the same way as other model components. The definition of an annotation starts with the ``annotation`` keyword, followed by the annotation name. A colon ``:`` punctuation introduces the rest of the definition, starting with a plain-text description of the annotation.

Annotation names must be unique across a model. The Rosetta DSL naming convention is to use a (lower) camelCase.

It is possible to associate attributes to an annotation (see `metadata <#metadata-label>`_ example), even though some annotations may not require any further attribute. For instance:

.. _roottype-label:

.. code-block:: Haskell

 annotation rootType: <"Mark a type as a root of the rosetta model">

 annotation deprecated: <"Marks a type, function or enum as deprecated and will be removed/replaced.">

An annotation can be added to a Rosetta Type or attribute by enclosing the name of the annotation in square brackets 

Meta-Data and Reference
^^^^^^^^^^^^^^^^^^^^^^^
Purpose
"""""""
.. _metadata-label:

The ``metadata`` annotation allows the declaration of a set of meta-data qualifiers that can be applied to types and attributes. By default Rosetta includes several metadata annotations 

.. code-block:: Haskell

 annotation metadata:
   id string (0..1)
   key string (0..1)
   scheme string (0..1)
   reference string (0..1)
   template string (0..1)
   location string (0..1) <"Specifies this is the target of an internal reference">
   address string (0..1) <"Specified that this is an internal reference to an object that appears elsewhere">

Each attribute of the ``metadata`` annotation corresponds to a qualifier that can be applied to a rosetta type or attribute:

* The ``scheme`` meta-data qualifier specifies a mechanism to control the set of values that an attribute can take. The relevant scheme reference may be specified as meta-information in the attribute's data source, so that no originating information is disregarded.
* The ``template`` meta-data qualifier indicates that a type is eligible to be used as a data template. Data templates provide a way to store data which may be duplicated across multiple objects into a single template, to be referenced by all these objects.
* the other metadata annotations above are used in referencing.

Referencing
"""""""""""
Referencing allows an attribute in rosetta to refer to a rosetta object in a different location. A reference consists of a metadata ID associated with an object and elsewhere an attribute that instead of having a normal value has that id as a reference metadata field. E.g. the example below has a Party with "globalKey" (see below) acting as an identifier and later on a reference to that party using the "globalReference" (see below also)::

 "party" : {
    "meta" : {
      "globalKey" : "3fa8e998",
      "externalKey" : "f845ge"
    },
    "name" : {
      "value" : "XYZ Bank"
    },
    "partyId" : [ {
      "value" : "XYZBICXXX",
      "meta" : {
        "scheme" : "http://www.fpml.org/coding-scheme/external/iso9362"
      }
    } ]
  }
 
 "partyReference" : {
        "globalReference" : "3d9e6ab8"
  }      


Rosetta currently supports 3 different mechanisms for references with different scopes. It is intended that these will all be migrated to a single mechanism.

Global References
/////////////////

The ``key`` and ``id`` metadata annotations cause a globally unique key to be generated for the rosetta object or attribute. The value of the key corresponds to a hash code to be generated by the model implementation. The implementation provided in the Rosetta DSL is a *deep hash* that uses the complete set of attribute values that compose the type and its attributes, recursively.

The ``reference`` metadata annotation denotes that an attribute can be either a direct value like any other attribute or can be replaces with a ``reference`` to a global key defined elsewhere. The key need not be defined in the current document but can instead be a reference to an external document.

External References
///////////////////

Attributes and types that have the ``key`` or ``id`` annotation additionally have an ``externalKey`` attached to them. This is used to store keys that are read from an external source e.g. FpML id metadata attribute. 

Attributes with the ``reference`` keyword have a corresponding externalReference field which is used to store references from external sources. The reference resolver processor can be used to link up the references.

Templates
/////////

When a type is annotated as a template, it is possible to specify a template reference that cross-references a template object. The template object, as well as any object that references it, are typically *incomplete* model objects that should not be validated individually. Once a template reference has been resolved, it is necessary to merge the template data to form a single fully populated object. Validation should only be performed once the template reference has been resolved and the objects merged together. 

Other than the new annotation, data templates do not have any impact on the model, i.e. no new types, attributes, or conditions.

.. note:: Some annotations, such as this metadata qualification, may be provided as standard as part of the Rosetta DSL itself. Additional annotations can always be defined for any model.

Syntax
""""""
Once an annotation is defined, its name and chosen attribute, if any, are used in between square brackets ``[`` ``]`` to annotate model components. The below ``Party`` and ``Identifier`` types illustrate how meta-data annotations and their relevant attributes can be used in a model:

.. code-block:: Haskell

 type Party:
   [metadata key]
   partyId string (1..*)
     [metadata scheme]
   name string (0..1)
     [metadata scheme]
   person NaturalPerson (0..*)
   account Account (0..1)

 type Identifier:
   [metadata key]
   issuerReference Party (0..1)
     [metadata reference]
   issuer string (0..1)
     [metadata scheme]
   assignedIdentifier AssignedIdentifier (1..*)

A ``key`` qualifier is associated to the ``Party`` type, which means it is referenceable. In the ``Identifier`` type, the ``reference`` qualifier, which is associated to the ``issuerReference`` attribute of type ``Party``, indicates that this attribute can be provided as a reference (via its associated key) instead of a copy. An example implementation of this cross-referencing mechanism for these types can be found in the `synonym <mapping.html>`_ of the documentation.

When a data type is annotated as a ``template``, the designation applies to all encapsulated types in that data type. In the example below, the designation of template eligibility for ``ContractualProduct`` also applies to ``EconomicTerms``, which is an encapsulated type in ``ContractualProduct``, and likewise applies to all encapsulated types in ``EconomicTerms``.

.. code-block:: Haskell

 type ContractualProduct:
   [metadata key]
   [metadata template]
   productIdentification ProductIdentification (0..1)
   productTaxonomy ProductTaxonomy (0..*)
   economicTerms EconomicTerms (1..1)

.. _qualification-label:

Qualified Type
^^^^^^^^^^^^^^
The Rosetta DSL provides for some special types called *qualified types*, which are specific to its application in the financial domain:

* Calculation - ``calculation``
* Object qualification - ``productType`` ``eventType``

Those special types are designed to flag attributes which result from running some logic, such that model implementations can identify where to stamp the output in the model. The logic is being captured by specific types of functions that are detailed in the `Function Definition Section <#function-label>`_.

Calculation
"""""""""""
The ``calculation`` qualified type, when specified instead of the type for the attribute, represents the outcome of a calculation. An example usage is the conversion from clean price to dirty price for a bond.

.. code-block:: Haskell

 type CleanPrice:
   cleanPrice number (1..1)
   accruals number (0..1)
   dirtyPrice calculation (0..1)

An attribute with the ``calculation`` type is meant to be associated to a function tagged with the ``calculation`` annotation. The attribute's type is implied by the function output.

.. code-block:: Haskell

 annotation calculation: <"Marks a function as fully implemented calculation.">

Object Qualification
""""""""""""""""""""
Similarly, ``productType`` and ``eventType`` represent the outcome of qualification logic to infer the type of an object (financial product or event) in the model. See the ``productQualifier`` attribute, alongside other identifier attributes in the ``ProductIdentification`` type:

.. code-block:: Haskell

 type ProductIdentification: <" A class to combine the CDM product qualifier with other product qualifiers, such as the FpML ones. While the CDM product qualifier is derived by the CDM from the product payout features, the other product identification elements are assigned by some external sources and correspond to values specified by other data representation protocols.">
   productQualifier productType (0..1) <"The CDM product qualifier, which corresponds to the outcome of the isProduct qualification logic. This value is derived by the CDM from the product payout features.">
   primaryAssetdata AssetClassEnum (0..1)
   secondaryAssetdata AssetClassEnum (0..*)
   productType string (0..*)
   productId string (0..*)

Attributes of these types are meant to be associated to an object qualification function tagged with the ``qualification`` annotation. The annotation has an attribute to specify which type of object (like ``Product`` or ``BusinessEvent``) is being qualified.

.. code-block:: Haskell

 annotation qualification: <"Annotation that describes a func that is used for event and product Qualification">
   [prefix Qualify]
   Product boolean (0..1)
   BusinessEvent boolean (0..1)

.. note:: The qualified type feature in the Rosetta DSL is under evaluation and may be replaced by a mechanism that is purely based on these function annotations in the future.

.. _expression-label:

Expression Component
--------------------

**The Rosetta DSL offers a restricted set of language features to express simple logic**, such as simple operations and comparisons. The language is designed to be unambiguous and understandable by domain experts who are not software engineers while minimising unintentional behaviour. Simple expressions can be built up using `operators <#operators-label>`_ to form more complex expressions.

.. note:: The Rosetta DSL is not a *Turing-complete* language: e.g. it does not support looping constructs that can fail (e.g. the loop never ends), nor does it natively support concurrency or I/O operations.

Logical expressions are used within the following model components:

- `Functions <#function-label>`_,
- `Data type validation conditions <#condition-label>`_,
- `Conditional mappings <#when-clause-label>`_ and 
- `Report Rules <#report-rule-label>`_

Expressions are evaluated within the context of a Rosetta object to return a result. The result of an expression can be either:

- a single `basic type <#basic-type-label>` value: e.g. 2.0, True, "USD",
- a single Rosetta object (data type or enumeration): e.g. a `Party` object or
- a `list <#list-label>`_ of results, all of the same type (basic type or Rosetta object).

The type of an expression is the type of the result that it will evaluate to. E.g. an expression that evaluates to True or False is of type boolean, an expression that evaluates to a list of `Party` is of type `List of Party`. 

The below sections detail the different types of Rosetta expressions and how they are used. 

.. _rosetta-path-label:

Rosetta Path Expression
^^^^^^^^^^^^^^^^^^^^^^^

Purpose
"""""""
A Rosetta path expression is used to return the value of an attribute inside a Rosetta object.

Syntax
""""""

The simplest Rosetta path expression is just the name of an attribute. In the example below, the ``before`` attribute of a ``ContractFormationPrimitive`` object is checked for `existence <#exists-label>`_ inside a `condition <#condition-label>` associated to that data type.

.. code-block:: Haskell
  :emphasize-lines: 7

  type ContractFormationPrimitive: 

	before ExecutionState (0..1) 
	after PostContractFormationState (1..1)

	condition: <"The quantity should be unchanged.">
		if before exists ....

Attribute names can be chained together using ``->`` in order to recursively refer to attributes further down inside that Rosetta object. In the example below, the ``security`` of the ``product`` contained in a ``Confirmation`` object is checked for `existence <#exists-label>`_.

.. code-block:: Haskell
  :emphasize-lines: 10

    type Confirmation: <"A class to specify a trade confirmation.">

        identifier Identifier (1..*) 
        party Party (1..*) 
        partyRole PartyRole (1..*) 
        lineage Lineage (0..1) 
        status ConfirmationStatusEnum (1..1)

        condition BothBuyerAndSellerPartyRolesMustExist: 
            if lineage -> executionReference -> tradableProduct -> product -> security exists

If a Rosetta path is applied to an attribute that does not have a value in the object it is being evaluated against, the result is *null* - i.e. there is no value. If an attribute of that non-existant object is further evaluated, the result is still *null*. In the above example, if `executionReference` is *null*, the final `security` attribute will also evaluate to *null*.

.. note:: In situations where the context of the object in which the Rosetta path expression should be evaluated is not already specified (e.g. reporting rules or conditional mapping), the Rosetta path should begin with the data type name e.g. ``WorkflowStep -> eventIdentifier``. where applicable, this requirement is enforced by syntax validation in the Rosetta DSL.

.. _list-label:

List
""""

A list is an ordered collection of items. A Rosetta path expression that refers to an attribute with multiple `cardinality <documentation.html#cardinality_label>`_ will result in a list of values. If a chained Rosetta path expression has multiple links with multiple cardinality then the result is a flattened list. For example (as extracted from the ``Qualify_CashTransfer`` function). ::

  businessEvent -> primitives -> transfer -> cashTransfer

gets all the `cashTransferComponent` from all the `primitive` attributes as a single list.

An expression that has the potential to return a value with *multiple cardinality* will always evaluate to a list of zero or more elements, regardless of whether the result contains a single or multiple elements.

Only element
""""""""""""
The keyword ``only-element`` can appear after an attribute name in a Rosetta path. ::

  observationEvent -> primitives only-element -> observation
	
This imposes a constraint that the evaluation of the path up to this point returns exactly one value. If it evaluates to `null <#null-label>`_\, an empty list or a list with more than one value then the expression result will be null.

Constant Expressions
^^^^^^^^^^^^^^^^^^^^

Purpose
"""""""

An expression can be a `basic type <#basic-type-label>`_ constant such as 2.0, True or "USD". Constant expressions are useful for comparisons to more complex expressions.

Enumeration Constant
""""""""""""""""""""

An expression can refer to a Rosetta Enumeration value using the name of the enumeration type followed by ``->`` and the name of the enumeration value. E.g. ::

  DayOfWeekEnum -> SAT

List Constant
"""""""""""""

Constants can also be declared as lists using a comma separated list of expressions enclosed within square brackets ``[...]``. E.g. ::

  [1,2]
  ["A",B"]
  [DayOfWeekEnum->SAT, DayOfWeekEnum->SUN]

.. _operators-label:

Operators
^^^^^^^^^

Purpose
"""""""

Rosetta supports operators that combine expressions into more complicated expressions. The language emulates the basic logic available in usual programming languages:

* conditional statements: ``if``, ``then``, ``else``
* comparison operators: ``=``, ``<>``, ``<``, ``<=``, ``>=``, ``>``
* list comparison operator: ``exists``, ``is absent``, ``contains``, ``count``
* boolean operators: ``and``, ``or``
* arithmetic operators: `+``, ``-``

Conditional Statement
"""""""""""""""""""""

Conditional statements consist of:

- an *if clause* with the keyword ``if`` followed by a boolean expression,
- a *then clause* with the keyword then followed by any expression and
- an optional *else clause* with the keyword ``else`` followed by any expression

If the *if clause* evaluates to True, the result of the *then clause* is returned by the conditional expression. If it evaluates to False, the result of the *else clause* is returned if present, else *null* is returned.

The type of the expression is the type of the expression contained in the *then clause*. The Rosetta DSL enforces that the type of the *else clause* matches the *then clause*. Multiple *else clauses* can be added by combining ``else if`` statements ending with a final ``else``.

Comparison Operators
""""""""""""""""""""
The result type of a comparison operator is always boolean

* ``=`` - Equals. Returns *true* if the left expression is equal to the right expression, otherwise false. Basic types are equal if their values are equal. Two complex rosetta types are equal if all of their attributes are equal, recursing down until all basic typed attributes are compared.
* ``<>`` - Does not equal. Returns *false* if the left expression is equal to the right expression, otherwise true.
* ``<``, ``<=``, ``>=``, ``>``  - performs mathematical comparisons on the left and right values. Both left and right have to evaluate to numbers or lists of numbers.
* ``exists`` - returns true if the left expression returns a result. This can be further modified with additional keywords.
  
  * ``only`` - the value of left expression exists and is the only attribute with a value in its parent object.
  * ``single`` - the value of expression either has single cardinality or is a list with exactly one value.
  * ``mutiple`` - the value expression has more than 2 results

* ``is absent`` - retuns true if the left expression does not return a result.

List Comparison Operators
"""""""""""""""""""""""""
Rosetta also has operators that are designed to function on lists

* ``contains`` - every element in the right hand expression is = to an element in the left hand expression
* ``disjoint`` - true if no element in the left side expression is equal to anu element in the right side expression
* ``count`` - returns the number of elements in the expression to its left
* ``(all\any) = (<>, < etc)``

If the contains operator is passed an expression that has single cardinality that expression is treated as a list containing the single element or an empty list if the element is null.

The grammar enforces that the expression for count has multiple cardinality. 

For the comparison operators if either left or right expression has multiple cardinality then either the other side should have multiple cardinality or `all` or `any` should be specified. (At present only `any` is supported for `<>` and `all` for the other comparison operators.

The semantics for list comparisons are as follows:

* ``=``
  
  * if both sides are lists then the lists must contain elements that are ``=`` when compared pairwise in the order
  * if the one side is a list and the other is single and `all` is specified then every element in the list must ``=`` the single value
  * if the one side is a list and the other is single and `any` is specified then at least one element in the list must ``=`` the single value (not implemented yet)

* ``<>``
  
  * if both sides are lists then then true is returned if the lists have different length or every element is ``<>`` to the corresonding element by position
  * if one side is a list and the `any` is specified then true is returned if any element ``<>`` the single element
  * if one side is a list and the `all` is specified then true is returned if all elements ``<>`` the single element (not implemented yet)

* ``<``, ``<=``, ``>=``, ``>``
  
  * if both sides are lists then every element in the first list must be ``>`` the element in the corresponding posistion in the second list
  * if one side is single and `all` is specified then every element in the list must be ``>`` that single value
  * if one side is single and `any` is specified then at least one element in the list must be ``>`` that single value (unimplemented)

An expression that is expected to return multiple cardinality that returns null is considered to be equivalent to an empty list

.. _null-label:

Comparison Operators and Null
"""""""""""""""""""""""""""""
If one or more expressions being passed to an operator is of single cardinality but is null (not present) the behavior is as follows

* null  = *any value* returns false
* null <> *any value* returns true
* null  > *any value* returns false
* null >= *any value* returns false

*any value* here includes null. The behaviour is symmetric - if the null appears on the either side of the expression the result is the same. if the null value is of multiple cardinality then it is treated as an empty list.

Boolean Operators
""""""""""""""""""""

``and`` and ``or`` can be used to logically combine boolean typed expressions.

``(`` and ``)`` can be used to group logical expressions. Expressions inside brackets are evaluated first.

Arithmetic Operators
""""""""""""""""""""
Rosetta supports basic arithmetic operators

* ``+`` can take either two numerical types or two string typed expressions. The result is the sum of two numerical types or the concatenation of two string types
* ``-``, ``*``, ``/`` take two numerical types and respectively subtract, multiply and divide them to give a number result.

Operator Precedence
"""""""""""""""""""
Expressions are evaluated in Rosetta in the following order (See `Operator Precedence <https://en.wikipedia.org/wiki/Order_of_operations>`_). Higher are evaluated first.

#. RosettaPathExpressions - e.g. 'Lineage -> executionReference'
#. Brackets - e.g. '(1+2)'
#. if-then-else - e.g. 'if (1=2) then 3'
#. only-element - e.g. 'Lineage -> executionReference only-element'
#. count - e.g. 'Lineage -> executionReference count'
#. Multiplicative operators '*','/' - e.g. '3*4'
#. Additive operators '+'.'-' - e.g. '3-4'
#. Comparison operators '>=', '<=','>','<' - e.g. '3>4
#. Existence operators 'exists','is absent','contains','disjoint' - e.g. 'Lineage -> executionReference exists'
#. and - e.g. '5>6 and true'
#. or - e.g. '5>6 or true'

Function calls
^^^^^^^^^^^^^^

Purpose
"""""""

An expression can be a call to a `function <#function-label>`_, that returns the output of that function evaluation.

Syntax
""""""
A function call consists of the function name, followed by a comma separated list of arguments enclosed within round brackets ``(...)``. 

The arguments list is a list of expressions. The number and type of the expressions must match the inputs defined by the function definition. This will be enforced by the syntax validator.

The type of a Function call expression is the type of the output of the called function.

In the last line of the example below the Max function is called to find the larger of the two WhichIsBigger function arguments, which is then compared to the first argument. The if expression surrounding this will then return "A" if the first argument was larger, "B" if the second was larger.

.. code-block:: Haskell
  :emphasize-lines: 18

    func Max:
        inputs:
            a number (1..1)
            b number (1..1)
        output:
            r number (1..1)
        assign-output r:
            if (a>=b) then a
            else b
            
    func WhichIsBigger:
        inputs:
            a number (1..1)
            b number (1..1)
        output:
            r string (1..1)
        assign-output r:
            if Max(a,b)=a then "A" else "B"


Data Validation Component
-------------------------
**Data integrity is supported by validation components that are associated to each data type** in the Rosetta DSL. There are two types of validation components:

* Cardinality
* Condition Statement

The validation components associated to a data type generate executable code designed to be executed on objects of that type. Implementors of the model can use the code generated from these validation components to build diagnostic tools that can scan objects and report on which validation rules were satisfied or broken. Typically, the validation code is included as part of any process that creates an object, to verify its validity from the point of creation.

.. _cardinality-label:

Cardinality
^^^^^^^^^^^

Cardinality is a data integrity mechanism to control how many of each attribute an object of a given type can contain. The Rosetta DSL borrows from XML and specifies cardinality as a lower and upper bound in between ``(`` ``..`` ``)`` brackets.

.. code-block:: Haskell

 type Address:
   street string (1..*)
   city string (1..1)
   state string (0..1)
   country string (1..1)
     [metadata scheme]
   postalCode string (1..1)

The lower and upper bounds can both be any integer number. A 0 lower bound means attribute is optional. A ``*`` upper bound means an unbounded attribute. ``(1..1)`` represents that there must be one and only one attribute of this type. When the upper bound is greater than 1, the attribute will be considered as a list, to be handled as such in any generated code.

A validation rule is generated for each attribute's cardinality constraint, so if the cardinality of the attribute does not match the requirement an error will be associated with that attribute by the validation process.

.. _condition-label:

Condition Statement
^^^^^^^^^^^^^^^^^^^

Purpose
"""""""

*Conditions* are logic `expressions <expressions.html>`_ associated to a data type. They are predicates on attributes of objects of that type that evaluate to True or False As part of validation all the conditions are evaluated and if any evaluate to false then the validation fails.

Syntax
""""""

Condition statements are included in the definition of the type that they are associated to and are usually appended after the definition of the type's attributes.

The definition of a condition starts with the ``condition`` keyword, followed by the name of the condition and a colon ``:`` punctuation. The condition's name must be unique in the context of the type that it applies to (but does not need to be unique across all data types of a given model). The rest of the condition definition comprises:

* a plain-text description (optional)
* a boolean-type `expression <expressions.html>`_ that applies to the the type's attributes

.. code-block:: Haskell

 type ActualPrice:
    currency string (0..1)
       [metadata scheme]
    amount number (1..1)
    priceExpression PriceExpressionEnum (1..1)

    condition Currency: <"The currency attribute associated with the ActualPrice should not be specified when the price is expressed as percentage of notional.">
       if priceExpression = PriceExpressionEnum -> PercentageOfNotional
       then currency is absent

.. code-block:: Haskell

 type ConstituentWeight:
    openUnits number (0..1)
    basketPercentage number (0..1)
    condition BasketPercentage: <"FpML specifies basketPercentage as a RestrictedPercentage type, meaning that the value needs to be comprised between 0 and 1.">
       if basketPercentage exists
       then basketPercentage >= 0.0 and basketPercentage <= 1.0

.. note:: Conditions are included in the definition of the data type that they are associated to, so they are "aware" of the context of that data type. This is why attributes of that data type can be directly used to express the validation logic, without the need to refer to the type itself.

Special Syntax
^^^^^^^^^^^^^^
Some specific language features have been introduced in the Rosetta DSL, to handle validation cases where the basic boolean logic components would create unnecessarily verbose, and therefore less readable, expressions. Those use-cases were deemed frequent enough to justify developing a specific syntax for them.

Choice
""""""
Choice rules define a choice constraint between the set of attributes of a type in the Rosetta DSL. They allow a simple and robust construct to translate the XML *xsd:choicesyntax*, although their usage is not limited to those XML use cases.

The choice constraint can be either:

* **optional**, represented by the ``optional choice`` syntax, when at most one of the attributes needs to be present, or
* **required**, represented by the ``required choice`` syntax, when exactly one of the attributes needs to be present

.. code-block:: Haskell

 type NaturalPerson: <"A class to represent the attributes that are specific to a natural person.">
   [metadata key]

   honorific string (0..1) <"An honorific title, such as Mr., Ms., Dr. etc.">
   firstName string (1..1) <"The natural person's first name. It is optional in FpML.">
   middleName string (0..*)
   initial string (0..*)
   surname string (1..1) <"The natural person's surname.">
   suffix string (0..1) <"Name suffix, such as Jr., III, etc.">
   dateOfBirth date (0..1) <"The natural person's date of birth.">

   condition Choice: <"Choice rule to represent an FpML choice construct.">
     optional choice middleName, initial

.. code-block:: Haskell

 type AdjustableOrRelativeDate:
   [metadata key]

   adjustableDate AdjustableDate (0..1)
   relativeDate AdjustedRelativeDateOffset (0..1)

   condition Choice:
     required choice adjustableDate, relativeDate

While most of the choice rules have two attributes, there is no limit to the number of attributes associated with it, within the limit of the number of attributes associated with the type.

.. note:: Members of a choice rule need to have their lower cardinality set to 0, something which is enforced by a validation rule.

One-of (as complement to choice rule)
"""""""""""""""""""""""""""""""""""""
In the case where all the attributes of a given type are subject to a required choice logic that results in one and only one of them being present in any instance of that type, the Rosetta DSL allows to associate a ``one-of`` condition to the type, as short-hand to by-pass the implementation of the corresponding choice rule.

This feature is illustrated below:

.. code-block:: Haskell

 type PeriodRange:
   lowerBound PeriodBound (0..1)
   upperBound PeriodBound (0..1)
   condition: one-of

Only Exists
"""""""""""
The ``only exists`` component is an adaptation of the simple ``exists`` syntax, that verifies that the attribute exists but also that no other attribute of the type does.

.. code-block:: Haskell

 type PriceNotation:
    price Price (1..1)
    assetIdentifier AssetIdentifier (0..1)

    condition CurrencyAssetIdentifier:
       if price -> fixedInterestRate exists
       then assetIdentifier -> currency only exists

    condition RateOptionAssetIdentifier:
       if price -> floatingInterestRate exists
       then assetIdentifier -> rateOption only exists

This syntax drastically reduces the condition expression, which would otherwise require to combine one ``exists`` with multiple ``is absent`` (applied to all other attributes). It also makes the logic more robust to future model changes, where newly introduced attributes would need to be tested for ``is absent``.

.. note:: This condition is typically applied to attributes of objects whose type implements a ``one-of`` condition. In this case, the ``only`` qualifier is redundant with the ``one-of`` condition because only one of the attributes can exist. However, ``only`` makes the condition expression more explicit, and also robust to potential lifting of the ``one-of`` condition.

.. _function-label:

Function Component
------------------
**In programming languages, a function is a fixed set of logical instructions returning an output** which can be parameterised by a set of inputs (also known as *arguments*). A function is *invoked* by specifying a set of values for the inputs and running the instructions accordingly. In the Rosetta DSL, this type of component has been unified under a single *function* construct.

Functions are a fundamental building block to automate processes, because the same set of instructions can be executed as many times as required by varying the inputs to generate a different, yet deterministic, result.

Just like a spreadsheet allows users to define and make use of functions to construct complex logic, the Rosetta DSL allows to model complex processes from reusable function components. Typically, complex processes are defined by combining simpler sub-processes, where one process's output can feed as input into another process. Each of those processes and sub-processes are represented by a function. Functions can invoke other functions, so they can represent processes made up of sub-processes, sub-sub-processes, and so on.

Reusing small, modular processes has the following benefits:

* **Consistency**. When a sub-process changes, all processes that use the sub-process benefit from that single change.
* **Flexibility**. A model can represent any process by reusing existing sub-processes. There is no need to define each process explicitly: instead, we pick and choose from a set of pre-existing building blocks.

Where widely adopted industry processes already exist, they should be reused and not redefined. Some examples include:

* Mathematical functions. Functions such as sum, absolute, and average are widely understood, so do not need to be redefined in the model.
* Reference data. The process of looking-up through reference data is usually provided by existing industry utilities and a model should look to re-use it but not re-implement it.
* Quantitative finance. Many quantitative finance solutions, some open-source, already defines granular processes such as:

  * computing a coupon schedule from a set of parameters
  * adjusting dates given a holiday calendar

This concept of combining and reusing small components is also consistent with a modular component approach to modelling.

Function Specification
^^^^^^^^^^^^^^^^^^^^^^
Purpose
"""""""
**Function specification components are used to define the processes applicable to a domain model** in the Rosetta DSL. A function specification defines the function's inputs and/or output through their *types* (or *enumerations*) in the data model. This amounts to specifying the `API <https://en.wikipedia.org/wiki/Application_programming_interface>`_ that implementors should conform to when building the function that supports the corresponding process.

Standardising those APIs guarantees the integrity, inter-operability and consistency of the automated processes supported by the domain model.

Syntax
""""""
Functions are defined in the same way as other model components. The syntax of a function specification starts with the keyword ``func`` followed by the function name. A colon ``:`` punctuation introduces the rest of the definition.

The Rosetta DSL convention for a function name is to use a PascalCase (upper `CamelCase`_) word. The function name needs to be unique across all types of functions in a model and validation logic is in place to enforce this.

The rest of the function specification supports the following components:

* plain-text descriptions
* inputs and output attributes (the latter is mandatory)
* condition statements on inputs and output
* output construction statements

Descriptions
""""""""""""
The role of a function must be clear for implementors of the model to build applications that provide such functionality. To better communicate the intent and use of functions, Rosetta supports multiple plain-text descriptions in functions. Descriptions can be provided for the function itself, for any input and output and for any statement block.

Look for occurrences of text descriptions in the snippets below.

Inputs and Output
"""""""""""""""""
Inputs and output are a function's equivalent of a type's attributes. As in a ``type``, each ``func`` attribute is defined by a name, data type (as either a ``type``, ``enum`` or ``basicType``) and cardinality.

At minimum, a function must specify its output attribute, using the ``output`` keyword also followed by a colon ``:``.

.. code-block:: Haskell

 func GetBusinessDate: <"Provides the business date from the underlying system implementation.">
    output:
      businessDate date (1..1) <"The provided business date.">

Most functions, however, also require inputs, which are also expressed as attributes, using the ``inputs`` keyword. ``inputs`` is plural whereas ``output`` is singular, because a function may only return one type of output but may take several types of inputs.

.. code-block:: Haskell

 func ResolveTimeZoneFromTimeType: <"Function to resolve a TimeType into a TimeZone based on a determination method.">
    inputs:
       timeType TimeTypeEnum (1..1)
       determinationMethod DeterminationMethodEnum (1..1)
    output:
       time TimeZone (1..1)
       
Inputs and outputs can both have multiple cardinality in which case they will be treated as lists

.. code-block:: Haskell

 func UpdateAmountForEachQuantity: 
   inputs:
      priceQuantity PriceQuantity (0..*) 
      amount number (1..1) 
   output:
      updatedPriceQuantity PriceQuantity (0..*) 

Conditions
""""""""""
A function's inputs and output can be constrained using *conditions*.

Condition statements in a function can represent either:

* a **pre-condition**, using the ``condition`` keyword, applicable to inputs only and evaluated prior to executing the function, or
* a **post-condition**, using the ``post-condition`` keyword, applicable to inputs and output and evaluated after executing the function (once the output is known)

Each type of condition keyword is followed by a `boolean expression <expressions.html>`_ which is evaluated to check the correctness of the function inputs and result.

Conditions are an essential feature of the definition of a function. By constraining the inputs and output, they define the constraints that implementors of this function must satisfy, so that it can be safely used for its intended purpose as part of a process.

.. code-block:: Haskell

 func EquityPriceObservation: <"Function specification for the observation of an equity price, based on the attributes of the 'EquityValuation' class.">
    inputs:
       equity Equity (1..1)
       valuationDate AdjustableOrRelativeDate (1..1)
       valuationTime BusinessCenterTime (0..1)
       timeType TimeTypeEnum (0..1)
       determinationMethod DeterminationMethodEnum (1..1)
    output:
       observation ObservationPrimitive (1..1)

    condition: <"Optional choice between directly passing a time or a timeType, which has to be resolved into a time based on the determination method.">
       if valuationTime exists then timeType is absent
       else if timeType exists then valuationTime is absent
       else False

    post-condition: <"The date and time must be properly resolved as attributes on the output.">
       observation -> date = ResolveAdjustableDate(valuationDate)
       and if valuationTime exists then observation -> time = TimeZoneFromBusinessCenterTime(valuationTime)
          else observation -> time = ResolveTimeZoneFromTimeType(timeType, determinationMethod)

    post-condition: <"The number recorded in the observation must match the number fetched from the source.">
       observation -> observation = EquitySpot(equity, observation -> date, observation -> time)

.. note:: The function syntax intentionally mimics the type syntax in the Rosetta DSL regarding the use of descriptions, attributes (inputs and output) and conditions, to provide consistency in the expression of model definitions.

Function Definition
^^^^^^^^^^^^^^^^^^^
**The Rosetta DSL allows to further define the business logic of a function**, by building the function output instead of just specifying the function's API. The creation of valid output objects can be fully or partially defined as part of a function specification, or completely left to the implementor. The parts of a function definition that have been fully defined as `Rosetta Expression <expressions.html>`_ will be be translated into functional code which don't require further implementation.

The return object or individual attributes of the return object can be set by the function definition using the assign-output syntax; the keyword ``assign-output`` is followed by a `Rosetta Path <expressions.html#rosetta-path-label>`_ , a ``:`` and then an `expression <expressions.html>`_ used to calculate the value from the inputs

* A function is **fully defined** when all validation constraints on the output object have been satisfied as part of the function specification. In this case, the generated code is directly usable in an implementation.
* A function is **partially defined** when the output object's validation constraints are only partially satisfied. In this case, implementors will need to extend the generated code and assign the remaining values on the output object.

A function must be applied to a specific use case in order to determine whether it is fully *defined* or *partially defined*.  There are a number of fully defined function cases explained in further detail below.

The Rosetta DSL only provides a limited set of language features. To build the complete processing logic for a *partially defined* function, model implementors are meant to extend the code generated from the Rosetta DSL once it is expressed in a fully featured programming language. For instance in Java, a function specification generates an *interface* that needs to be extended to be executable.

The output object will be systematically validated when invoking a function, so all functions require the output object to be fully valid as part of any model implementation.

Output Construction
"""""""""""""""""""
In the ``EquityPriceObservation`` example above, the ``post-condition`` statements assert whether the observation's date and value are correctly populated according to the output of other, sub-functions, but delegates the construction of that output to implementors of the function.

In practice, implementors of the function can be expected to re-use those sub-functions (``ResolveAdjustableDate`` and ``EquitySpot``) to construct the output. The drawback is that those sub-functions are likely to be executed twice: once to build the output and once to run the validation.

For efficiency, the function syntax in the Rosetta DSL allows to directly build the output by assigning its values. Function implementors do not have to build those values themselves, because the function already provides them by default, so the corresponding post-conditions are redundant and can be removed.

The example above could be rewritten as follows:

.. code-block:: Haskell

 func EquityPriceObservation:
    inputs:
       equity Equity (1..1)
       valuationDate AdjustableOrRelativeDate (1..1)
       valuationTime BusinessCenterTime (0..1)
       timeType TimeTypeEnum (0..1)
       determinationMethod DeterminationMethodEnum (1..1)
    output:
       observation ObservationPrimitive (1..1)

    condition:
       if valuationTime exists then timeType is absent
       else if timeType exists then valuationTime is absent
       else False

    assign-output observation -> date:
       ResolveAdjustableDate(valuationDate)

    assign-output observation -> time:
       if valuationTime exists then TimeZoneFromBusinessCenterTime(valuationTime)
       else ResolveTimeZoneFromTimeType(timeType, determinationMethod)

    assign-output observation -> observation:
       EquitySpot(equity, observation -> date, observation -> time)

**The Rosetta DSL also supports a number of fully defined function cases**, where the output is being built up to a valid state:

* Object qualification
* Calculation
* Short-hand function

Those functions are typically associated to an annotation, as described in the `Qualified Type Section <#qualified-label>`_, to instruct code generators to create concrete functions.

Object Qualification Function
"""""""""""""""""""""""""""""

**The Rosetta DSL supports the qualification of financial objects from their underlying components** according to a given classification taxonomy, in order to support a composable model for those objects (e.g. financial products, legal agreements or their associated lifecycle events).

Object qualification functions evaluate a combination of assertions that uniquely characterise an input object according to a chosen classification. Each function is associated to a qualification name (a ``string`` from that classification) and returns a boolean. This boolean evaluates to True when the input satisfies all the criteria to be identified according to that qualification name.

Object qualification functions are associated to a ``qualification`` annotation that specifies the type of object being qualified. The function name start with the ``Qualify`` prefix, followed by an underscore ``_``. The naming convention is to have an upper `CamelCase`_ (PascalCase) word, using ``_`` to append granular qualification names where the classification may use other types of separators (like space or colon ``:``).

Syntax validation logic based on the ``qualification`` annotation is in place to enforce this.

.. code-block:: Haskell

 func Qualify_InterestRate_IRSwap_FixedFloat_PlainVanilla: <"This product qualification doesn't represent the exact terms of the ISDA Taxonomomy V2.0 for the plain vanilla swaps, as some of those cannot be represented as part of the CDM syntax (e.g. the qualification that there is no provision for early termination which uses an off-market valuation), while some other are deemed missing in the ISDA taxonomy and have been added as part of the CDM (absence of cross-currency settlement provision, absence of fixed rate and notional step schedule, absence of stub). ">
   [qualification Product]
   inputs: economicTerms EconomicTerms (1..1)
   output: is_product boolean (1..1)

Calculation Function
""""""""""""""""""""

Calculation functions define a calculation output that is often, though not exclusively, of type ``number``. They must end with an ``assign-output`` statement that fully defines the calculation result.

Calculation functions are associated to the ``calculation`` annotation.

.. code-block:: Haskell

 func FixedAmount:
   [calculation]
   inputs:
     interestRatePayout InterestRatePayout (1..1)
     fixedRate FixedInterestRate (1..1)
     quantity NonNegativeQuantity (1..1)
     date date (1..1)
   output:
     fixedAmount number (1..1)

   alias calculationAmount: quantity -> amount
   alias fixedRateAmount: fixedRate -> rate
   alias dayCountFraction: DayCountFraction(interestRatePayout, interestRatePayout -> dayCountFraction, date)

   assign-output fixedAmount:
     calculationAmount * fixedRateAmount * dayCountFraction

Alias
"""""

The function syntax supports the definition of *aliases* that are only available in the context of the function. Aliases work like temporary variable assignments used in programming languages and are particularly useful in fully defined functions.

The above example builds an interest rate calculation using aliases to define the *calculation amount*, *rate* and *day count fraction* as temporary variables, and finally assigns the *fixed amount* output as the product of those three variables.

Short-Hand Function
"""""""""""""""""""

Short-hand functions are functions which are designed to provide a compact syntax for operations that need to be frequently invoked in the model - for instance, model indirections when the corresponding model expression may be deemed too long or cumbersome:

.. code-block:: Haskell

 func PaymentDate:
   inputs: economicTerms EconomicTerms (1..1)
   output: result date (0..1)
   assign-output result: economicTerms -> payout -> interestRatePayout only-element -> paymentDate -> adjustedDate

which could be invoked as part of multiple other functions that use the ``EconomicTerms`` object by simply stating:

.. code-block:: Haskell

 PaymentDate( EconomicTerms )

.. _namespace-label:

Namespace Component
--------------------
Namespace Definition
^^^^^^^^^^^^^^^^^^^^
Purpose
"""""""
The namespace syntax allows model artefacts in a data model to be organised into groups of namespaces. A namespace is an abstract container created to hold a logical grouping of model artefacts. The approach is designed to make it easier for users to understand the model structure and adopt selected components. It also aids the development cycle by insulating groups of components from model restructuring that may occur.  Model artefacts are organised into a directory structure that follows the namespaces’ Group and Artefact structure (a.k.a. “GAV coordinates”). This directory structure is exposed in the model editor.

By convention namespaces are organised into a hierarchy, with layers going from in to out. The hierarchy therefore contains an intrinsic inheritance structure where each layer has access to (“imports”) the layer outside, and is designed to be usable without any of its inner layers. Layers can contain several namespaces (“siblings”), which can also refer to each other. 

Syntax
""""""

The definition of a namespace starts with the `namespace` keyword, followed by the location of the namespace in the directory structure. ::

  namespace cdm.product.common

The names of all components must be unique within a given namespace. Components can refer to other components in the same namespace using just their name. Components can refer to components outside their namespace either by giving the *fully qualified name* e.g. ``cdm.base.datetime.AdjustableDate`` or by importing the namespace into the current file.

To gain access to model components contained within another namespace the `import` keyword is used. ::

  import cdm.product.asset.*

In the example above all model components contained within the cdm.product.asset namespace will be imported. Note, only components contained within the layer referenced will be imported, in order to import model components from namespaces embedded within that layer further namespaces need to be individually referenced. ::

  import cdm.base.math.*
  import cdm.base.datetime.*
  import cdm.base.staticdata.party.*
  import cdm.base.staticdata.asset.common.*
  import cdm.base.staticdata.asset.rates.*
  import cdm.base.staticdata.asset.credit.*

In the example above all model components contained within the layers of the `cdm.base` namespace are imported.

Mapping Component
-----------------

Mapping in Rosetta provides a mechanism for specifying how documents that are not Rosetta documents should be transformed into Rosetta documents. For more information see `mapping <mapping.html>`_

Purpose
^^^^^^^

Mappings in Rosetta are the annotations on the model that specify how input documents in other formats (e.g. FpML or ISDACreate json) can be transformed into Rosetta documents. Mappings are specified in the model as synonyms. 

Synonyms added throughout the model are combined to map the data tree of an input document into the output Rosetta document. The synonyms can be used to generate an *Ingestion Environment*, a library of java that when given an input document will output the resulting Rosetta document.

Synonyms are specified on the attributes of data type and the values of enum types.


Basic Mappings
^^^^^^^^^^^^^^
Basic mappings specify how a value from the input document can be directly mapped to a value in the resulting Rosetta document.

Synonym Source
""""""""""""""
First a *synonym source* is created. This can optionally extend a different synonym source
``synonym source FpML_5_10 extends FpML``
This defines a set of synonyms that are used to ingest a category of input document, in this case FpML_5_10 documents

Extends
/////////////////
A synonym source can extend another synonym source. This forms a new synonym source that has all the synonyms contained in the extended synonym source and can add additional synonyms as well as remove synonyms from it.

Basic Synonym
""""""""""""""
Synonyms are annotations on attributes of Rosetta types and the enumeration values of Rosetta Enums.  The model does have some legacy synonyms remaining 
directly on rosetta types but the location of the synonym in the model has no impact. They can be written inside the definition of the type or they can be specified in a separate file to leave the type definitions simpler.

Inline
/////////////////
An inline synonym consists of '[' followed by the keyword *synonym* and the name of the synonym source followed by the body of the synonym and an ']' ::

	type Collateral:
		independentAmount IndependentAmount (1..1)
			[synonym FpML_5_10 value "independentAmount"]


External synonym
/////////////////
External synonyms are defined inside the synonym source declaration so the synonym keyword and the synonym source are not required in every synonym. 
A synonym is added to an attribute by referencing the type and attribute name and then declaring the synonym to add as the synonym body surrounded by '[]'. The code below removes all the synonyms from the independentAmount attribute of Collateral and then adds in a new synonym ::

	synonym source FpML_5_10 extends FpML
	{
		Collateral:
			- independentAmount
			+ independentAmount
				[value "independentAmount"]
	}

Synonym Body
""""""""""""""
Value
/////////////////
The simplest synonym consists of a single value ``[value "independentAmount"]``. This means that the value of the input attribute "independentAmount" will be mapped to the associated Rosetta attribute. If both the input attribute and the Rosetta attribute are basic types (string, number, date etc) then the input value will be stored in the appropriate place in the output document. If they are both complex types (with child attributes of their own) then the attributes contained within the complex type will be compared against synonyms inside the corresponding Rosetta type. If one is complex and the other is basic then a mapping error will be recorded.

Path
/////////////////
The value of a synonym can be followed with a path declaration. E.g. ``[value "initialFixingDate" path "resetDates"]``. This allows a path of input document elements to be matched to a single Rosetta attribute. In the example the contents of the xml path "resetDates.initialFixingDate" will be mapped to the Rosetta attribute. Note that the path is applied as a suffix to the synonym value.

Maps 2
/////////////////
Mappings are expected to be one-to-one with each input value mapping to one Rosetta value. By default if a single input value is mapped to multiple Rosetta output values this is considered an error. However by adding the "maps 2" keyword this can be overridden allowing the input value to map to many output Rosetta values.

meta
/////////////////
The *meta* keyword inside a synonym is used to map to Rosetta `metadata <documentation.html#metadata-label>`_. E.g. ::

	issuer string (0..1)
     [metadata scheme]
     [synonym FpML_5_10 value "issuer" meta "issuerIdScheme"]

the input value associated withe "issuer" will be mapped to the value of the attribute issuer and the value of "issuerIdScheme" will be mapped to the scheme metadata attribute.

Enumerations
""""""""""""""
A synonym on an enumeration provides mappings from the string values in the input document to the values of the enumeration. E.g. the fpml value 'Broker' will be mapped to the Rosetta enum value *NaturalPersonRoleEnum.Broker* ::

	enum NaturalPersonRoleEnum: <"The enumerated values for the natural person's role.">

   	Broker <"The person who arranged with a client to execute the trade.">
    	 [synonym FpML_5_10 value "Broker"]

External enumeration synonyms
/////////////////
In an external synonym file ``enum`` synonyms are defined in a block after the type attribute synonyms, preceded by the keyword *enums* ::

	enums

	NaturalPersonRoleEnum:
		+ Broker
			[value "Broker"]

Advanced Mapping
^^^^^^^^^^^^^^^^
The algorithm starts by *binding* the root of the input document to a pre-defined Rosetta `root type <documentation.html#roottype-label>`_

It then `recursively <https://en.wikipedia.org/wiki/Recursion_(computer_science)>`_ traverses the input document.

Each step of the algorithm starts with the current attribute in the input document *bound* to a set of Rosetta objects in the output Rosetta document.

For each child attribute of the current input attribute, the rosetta attributes of the type of all Rosetta objects *bound* to the current attribute are checked for synonyms that match that child attribute. For each matching attribute a new Rosetta object instance is created and *bound* to that child attribute. The algorithm then recurses with the current child becoming the current input attribute.

When an input attribute has an associated value that value is set as the value of all the rosetta objects that are bound to the input attribute.

Hints
""""""""""""""
Hints are synonyms used to bypass a layer of rosetta without *consuming* an input attribute. They are required where an attribute has synonyms that would usually prevent the algorithm for searching down the Rosetta tree for attributes further down, but the current input element needs to still be available to match to synonyms.

e.g. ::

	ResolvablePayoutQuantity:
		+ assetIdentifier
			[value "notionalAmount"]
			[hint "currency"]

	AssetIdentifier:
		+ currency
			[value "currency" maps 2 meta "currencyScheme"]

In this example the input attribute "notionalAmount" is matched to the assetIdentifier and the children of "notionalAmount" will be matched against the synonyms for AssetIdentifier. However the input attribute "currency" will also be matched to the assetIdentifier but "currency" is still available to be matched against the synonyms of AssetIdentifier. 

Merging inputs
""""""""""""""
Where a Rosetta attribute exists with multiple cardinality, to which more than one input element maps, synonyms can be used to either create a single instance of the Rosetta attribute that merges the input elements or to create multiple attributes - one for each input element. E.g.
The synonyms ::

	interestRatePayout InterestRatePayout (0..*)
		[synonym FpML_5_10 value feeLeg]
		[synonym FpML_5_10 value generalTerms]

will produce two InterestRatePayout objects. In order to create a single InterestRatePayout with values from the FpML feeLeg and generalTerms the synonym merging syntax should be used::

	interestRatePayout InterestRatePayout (0..*)
		[synonym FpML_5_10 value feeLeg, generalTerms]

Conditional Mappings
""""""""""""""

Conditional mappings allow more complicated mappings to be done. Conditional mappings come in two types, `Set To <#set-to-label>`_ and `Set When <#set-when-label>`_.

.. _set-to-label:

Set To Mappings
/////////////////

Set To mappings are used to set the value of the Rosetta attribute to a constant value.
They don't attempt to use any data from the input document as the value for the attribute and a synonym value must not be given.
The type of the constant must be convertible to the type of the attribute.
The constant value can be given as a string (converted as necessary) or an enum.

e.g. ::

	period PeriodEnum (1..1)
		[synonym ISDA_Create_1_0 set to PeriodEnum.D]
	itemName string (1..1) <"In this ....">;
		[synonym DTCC_11_0 set to "comment"]

A set to mapping can be conditional on a `when clause <#when-clause-label>`_

e.g. ::

	itemName string (1..1) <"In this ....">;
		[synonym DTCC_11_0 set to "comment" when path = "PartyWorkflowFields.comment"]

multiple Set Tos can be combined in one synonym. They will be evaluated in the order specified with the first matching value used

e.g. ::

	xField string (1..1);
		[synonym Bank_A
			set to "FISH2" when "b.c.d" = "FISH",
			set to "SAUSAGE2" when "b.c.d" = "SAUSAGE",
			set to "DEFAULT"]


.. _set-when-label:

Set When mappings
/////////////////
A set when mapping is used to set an attribute to a value derived from the input document if a given when clause is met

e.g. ::

	execution Execution (0..1) <"The execution ...">;
		[synonym CME_SubmissionIRS_1_0 value TrdCaptRpt set when "TrdCaptRpt.VenuTyp" exists]

A Set when synonym can include a default.
Default mappings can be used to set an attribute to a constant value when no other value was applicable

e.g. ::

		[synonym Bank_A value e path "b.c" default to "DEFAULT"]

. _when-clause-label:
When clauses
""""""""""""""
There are three types of when clause; Test expression, Path expression or RosettaPath expression.

Test Expression
/////////////////
A test expression consists of a synonym path and one of three types of test. The synonym path is from the mapping that bound to this class.

* exists - tests whether a value with the given path exists in the input document
* absent - tests that a value with given path does not exist in the input document
* = or <> - tests if the value for the given path equals (or is not equal to) a constant value

e.g. ::

	execution Execution (0..1) <"The execution ...">;
		[synonym Rosetta_Workbench value trade set when "trade.executionType" exists]
	contract Contract (0..1) <"The contract ... ">;
		[synonym Rosetta_Workbench value trade set when "trade.executionType" is absent]
	discountingType DiscountingTypeEnum (1..1) <"The discounting method that is applicable.">;
		[synonym FpML_5_10 value fraDiscounting set when "fraDiscounting" <> "NONE"]

Path Expression
/////////////////
A Path expression checks the path through the rosetta document that leads to the current rosetta object. The path provided can only be the direct path from the level about in the document; in order for the condition to be true then the current path has to be the given path.::

	role PartyRoleEnum (1..1) <"The party role.">;`
		[synonym FpML_5_10 set to PartyRoleEnum.DeterminingParty when path = "trade.determiningParty"]

RosettaPath Expression
/////////////////
A rosettaPath expression checks the path through the rosetta document that leads to the current rosetta object. The path provided can start from any level in the document; in order for the condition to be true then the current path has to end with the given path.

e.g. ::

	identifier string (1..1) scheme <"The identifier value.">;
		[synonym DTCC_11_0, DTCC_9_0 value tradeId path "partyTradeIdentifier"
			set when rosettaPath = Event -> eventIdentifier -> assignedIdentifier -> identifier]

Mapper
""""""""""""""
Occasionally the Rosetta mapping syntax is not powerful enough to perform the required transformation from the input document to the output document. In this case a *Mapper* can be called from a synonym ::

	NotifyingParty:
			+ buyer
				[value "buyerPartyReference" mapper "CounterpartyEnum"]

When the ingestion is run a class called CounterPartyMappingProcessor will be loaded and its mapping method invoked with the partially mapped Rosetta element. The creation of mapper classes is outside the scope of this document but the full power of the programming language can be used to transform the output.

Format
""""""""""""""
A date/time synonym can be followed by a format construct. The keyword `format` should be followed by a string. The string should be a `Date format <https://docs.oracle.com/javase/8/docs/api/java/time/format/DateTimeFormatter.html>`_

E.g. ::

	[value "bar" path "baz" format "MM/dd/yy"]


Pattern
""""""""""""""
A synonym can optionally be followed by a the pattern construct. It is only applicable to enums and basic types other than date/times. The keyword `pattern` followed by two quoted strings. The first string is a `regular expression <https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html>`_ 
used to match against the input value. The second string is a replacement expression used to reformat the matched input before it is processed as usual for the basictype/enum. 

E.g. ::

	[value "Tenor" maps 2 pattern "([0-9]*).*" "$1"]


.. _reporting-component-label:

Reporting Component
-------------------

Motivation
^^^^^^^^^^

**One of the applications of the Rosetta DSL is to facilitate the process of complying with, and supervising, financial regulation** – in particular, the large body of data reporting obligations that industry participants are subject to.

The current industry processes to implement those rules are costly and inefficient. They involve translating pages of legal language, in which the rules are originally written, into business requirements which firms then have to code into their systems to support the regulatory data collection. This leads to a duplication of effort across a large number of industry participants and to inconsistencies in how each individual firm applies the rules, in turn generating data of poor quality and comparability for regulators.

By contrast, a domain-model for the business process or activity being regulated provides standardised, unambiguous definitions for business data at the source. In turn, these business data can be used as the basis for the reporting process, such that regulatory data become unambiguous views of the business data.

The Rosetta DSL allows to express those reporting rules as functional components in the same language as the model for the business domain itself. Using code generators, those functional rules are then distributed as executable code, for all industry participants to use consistently in their compliance systems.


Regulatory Hierarchy
^^^^^^^^^^^^^^^^^^^^

Purpose
"""""""

One of the first challenges of expressing regulatory rules for the financial domain is to organise the content of the regulatory framework that mandates these rules. The financial industry is a global, highly regulated industry, where a single line of business or activity may operate across multiple jurisdictions and regulatory regimes. The applicable regulations can span thousands of pages of legal text with intricate cross-references.

Syntax
""""""

To organise such regulatory content within a model, the Rosetta DSL supports a number of syntax components that allow to refer to specific documents, their content and who owns them as direct model components. Those components are defined in the `document reference hierarchy <#document-reference-hierarchy-label>`_ section.

Report Definition
^^^^^^^^^^^^^^^^^

Purpose
"""""""

A report consists of an inter-connected set of regulatory obligations, which a regulated entity must implement to produce data as required by the relevant regulator.

Generically, the Rosetta DSL allows to specify any report using 3 types of rules:

- timing – when to report,
- eligibility – whether to report, and
- field – what to report.

A report is associated to an authoritative body and to the corpus(es) in which those rules are specified. Usually but not necessarily, the authority that mandates the rules also supervises their application and collects the data. Timing, eligibility and field rules translate into obligations of “timing, completeness and accuracy” of reporting, as often referred to by supervisors.

Syntax
""""""

A report is specified using the following syntax:

.. code-block:: Haskell

 report <Authority> <Corpus1> <Corpus2> <...> in <TimingRule>
   when <EligibilityRule1> and <EligibilityRule2> and <...>
   with fields <FieldRule1> <FieldRule2> <...>

An example is given below.

.. code-block:: Haskell

 report MAS SFA MAS_2013 in T+2
   when ReportableProduct and NexusCompliant
   with fields
     UniqueTransactionIdentifier
     UniqueProductIdentifier
     PriorUniqueTransactionIdentifier
     Counterparty1
     Counterparty2

To ensure a model’s regulatory framework integrity, the authority, corpus and all the rules referred to in a report definition must exist as model components in the model’s regulatory hierarchy. A report simply assembles all those existing components into a *recipe*, which firms can directly implement to comply with the reporting obligation and provide the data as required.

The next section describes how to define reporting rules as model components.

.. _report-rule-label:

Rule Definition
^^^^^^^^^^^^^^^

Purpose
"""""""

The Rosetta DSL applies a functional approach to the process of regulatory reporting. A regulatory rule is a functional model component (``F``) that processes an input (``X``) through a set of logical instructions and returns an output (``Y``), such that ``Y = F( X )``. A function ``F`` can sometimes also be referred to as a *projection*. Using this terminology, the reported data (``Y``) are viewed as projections of the business data (``X``).

For field rules, the output ``Y`` consists of the data point to be reported. For eligibility rules, this output is a Boolean that returns True when the input is eligible for reporting.

To provide transparency and auditability to the reporting process, the Rosetta DSL supports the development of reporting rules in both human-readable and machine-executable form.

- The functional expression of the reporting rules is designed to be readable by professionals with domain knowledge (e.g. regulatory analysts). It consists of a limited set of logical instructions, supported by the compact Rosetta DSL syntax.
- The machine-executable form is derived from this functional expression of the reporting logic using the Rosetta DSL code generators, which directly translate it into executable code.
- In addition, the functional expression is explicitly tied to regulatory references, using the regulatory hierarchy concepts of body, corpus and segment to point to specific text provisions that support the reporting logic. This mechanism, coupled with the automatic generation of executable code, ensures that a reporting process that uses that code is fully auditable back to any applicable text.

Syntax
""""""

The syntax of reporting field rules is as follows:

.. code-block:: Haskell

 <RuleType> rule <Name>
   [regulatoryReference <Body> <Corpus>
     <Segment1>
     <Segment2>
     <SegmentN...>
     provision <"ProvisionText">]
   <FunctionalExpression>

The <RuleType> can be either ``reporting`` or ``eligibility``. The ``regulatoryReference`` syntax is the same as the ``docReference`` syntax documented in the `document reference <#document-reference-label>`_ section. However it can only be applied to regulatory rules.

The functional expression of reporting rules uses the same syntax components that are already available to express logical statements in other modelling components, such as the condition statements that support data validation.

Functional expressions are composable, so a rule can also call another rule. When multiple rules may need to be applied for a single field or eligibility criteria, those rules can be specified in brackets separated by a comma. An example is given below for the *Nexus* eligibility rule under the Singapore reporting regime, where ``BookedInSingapore`` and ``TradedInSingapore`` are themselves eligibility rules.

.. code-block:: Haskell

 eligibility rule NexusCompliant
   [regulatoryReference MAS SFA MAS_2013
      part "1"
      section "Citation and commencement"
      provision "In these Regulations, unless the context otherwise requires; Booked in Singapore, Traded in Singapore"]
   (
     BookedInSingapore,
     TradedInSingapore
   )

In addition to those existing functional features, the Rosetta DSL provides other syntax components that are specifically designed for reporting applications. Those components are:

- ``extract`` <Expression>

When defining a reporting rule, the `extract` keyword defines a value to be reported, or to be used as input into a subsequent statement or another rule. The full expressional syntax of the Rosetta DSL can be used in the expression that defines the value to be extracted, including conditional statement such as ``if`` / ``else`` / ``or`` / ``exists``.

An example is given below, that uses a mix of Boolean statements. This example looks at the fixed and floating rate specification of an InterestRatePayout and if there is one of each returns true

.. code-block:: Haskell

 reporting rule IsFixedFloat
   extract Trade -> tradableProduct -> product -> contractualProduct -> economicTerms -> payout -> interestRatePayout -> rateSpecification -> fixedRate count = 1
   and Trade -> tradableProduct -> product -> contractualProduct -> economicTerms -> payout -> interestRatePayout -> rateSpecification -> floatingRate count = 1

The extracted value may be coming from a data attribute in the model, as above, or may be directly specified as a value, such as a ``string`` in the below example.

.. code-block:: Haskell

 extract if WorkflowStep -> businessEvent -> primitives -> execution exists
   or WorkflowStep -> businessEvent -> primitives -> contractFormation exists
   or WorkflowStep -> businessEvent -> primitives -> quantityChange exists
     then "NEWT"

- <ReportExpression1> ``then`` <ReportExpression2>

Report statements can be chained using the keyword ``then``, which means that extraction continues from the previous point.

The syntax provides type safety when chaining rules, whereby the output type of the preceding rule must be equal to the input type of the following rule. The example below uses the TradeForEvent rule to find the Trade object and ``then`` extracts the termination date from that trade

.. code-block:: Haskell

 reporting rule MaturityDate <"Date of maturity of the financial instrument. Field only applies to debt instruments with defined maturity">
 	TradeForEvent then extract Trade -> tradableProduct -> product -> contractualProduct -> economicTerms -> terminationDate -> adjustableDate -> unadjustedDate

 reporting rule TradeForEvent
 	extract
 		if WorkflowStep -> businessEvent -> primitives -> contractFormation -> after -> trade only exists
	then WorkflowStep -> businessEvent -> primitives -> contractFormation -> after -> trade
		else WorkflowStep -> businessEvent -> primitives -> contractFormation -> after -> trade

- ``as`` <FieldName>

Any report statement can be follows by ``as`` This sets a label under which the value will appear in a report, as in the below example.

.. code-block:: Haskell

 reporting rule RateSpecification
   extract Trade -> tradableProduct -> product -> contractualProduct -> economicTerms -> payout -> interestRatePayout -> rateSpecification
   as "Rate Specification"

The label is an arbitrary ``string`` and should be aligned with the name of the reportable field as per the regulation. This field name will be used as column name when displaying computed reports, but is otherwise not functionally usable.

- ``Rule if`` statement

The rule if statement consists of the keyword ``if`` followed by condition that will be evaluated ``return`` followed by a rule. 
If the condition is true then the value of the ``return`` rule is returned.
Additional conditions and ``return`` rules can be specified with ``else if``. Only the first matching condition's ``return`` will be executed.
``else return`` can be used to provide an alternative that will be executed if no conditions match
In the below example we first extract the Payout from a Trade then we try to find the appropriate asset class.
If there is a ForwardPayout with a foreignExchange underlier then "CU" is returned as the "2.2 Asset Class"
If there is an OptionPayout with a foreignExchange underlier then "CU" is returned as the "2.2 Asset Class"
otherwise the asset class is null

.. code-block:: Haskell

  extract Trade -> tradableProduct -> product -> contractualProduct -> economicTerms -> payout then
  if filter when Payout -> forwardPayout -> underlier -> underlyingProduct -> foreignExchange exists
	    do return "CU" as "2.2 Asset Class"
	  else if filter when Payout -> optionPayout -> underlier -> underlyingProduct -> foreignExchange exists
	    do return "CU" as "2.2 Asset Class",
		do return "null" as "2.2 Asset Class"
	endif

Filtering Rules
///////////////

Filtering and max/min/first/last rules take a collection of input objects and return a subset of them. The output type of the rule is always the same as the input.

- ``filter when`` <FunctionalExpression>

The ``filter when`` keyword takes each input value and uses it as input to a provided test expression The result type of the test expression must be boolean and its input type must be the input type of the filter rule. 
If the expression returns ``true`` for a given input that value is included in the output.
The code below selects the PartyContactInformation objects then filters to only the parties that are reportingParties before then returning the partyReferences

.. code-block:: Haskell

 reporting rule ReportingParty <"Identifier of reporting entity">
   TradeForEvent then extract Trade -> partyContractInformation then
   filter when PartyContractInformation -> relatedParty -> role = PartyRoleEnum -> ReportingParty then
   extract PartyContractInformation -> partyReference

The functional expression can be either a direct Boolean expression as above, or the output of another rule, in which case the syntax is: ``filter when rule`` <RuleName>, as in the below example.
This example filters all the input trades to return only the ones that InterestRatePayouts and then extracts the fixed interest rate for them.

.. code-block:: Haskell

 reporting rule FixedFloatRateLeg1 <"Fixed Float Price">
   filter when rule IsInterestRatePayout then
   TradeForEvent then extract Trade -> tradableProduct -> priceNotation -> price -> fixedInterestRate -> rate as "II.1.9 Rate leg 1"

And the filtering rule is defined as:

.. code-block:: Haskell

 reporting rule IsInterestRatePayout
   TradeForEvent then
   extract Trade -> tradableProduct -> product -> contractualProduct -> economicTerms -> payout -> interestRatePayout only exists

- ``maximum`` / ``minimum``

The ``maximum`` and ``minimum`` keywords return only a single value (for a given key). The value returned will be the highest or lowest value. The input type to the rule must be of a comparable basic data type
e.g. date, time, number, string
In the below example, we first apply a filter and extract a ``rate`` attribute. There could be multiple rate values, so we select the highest one.

.. code-block:: Haskell

 filter when rule IsFixedFloat then
   extract Trade -> tradableProduct -> priceNotation -> price -> fixedInterestRate -> rate then
   maximum

- ``maxBy`` / ``minBy``

The syntax also supports selecting values by an ordering based on an attribute using the ``maxBy`` and ``minBy`` keywords. For each input value to the rule the provided test expression or rule is evaluated to give a test result and paired with the input value. 
When all values have been processes the pair with the highest test result is selected and the associated value is returned by the rule.
The test expression or rule must return a value of single cardinality and must be of a comparable basic data type
e.g. date, time, number, string
In the below example, we first apply a filter and extract a ``fixedInterestRate`` attribute. There could be multiple attribute values, so we select the one with the highest rate and return that FixedInterestRate object.

.. code-block:: Haskell

 filter when rule IsFixedFloat then
   extract Trade -> tradableProduct -> priceNotation -> price -> fixedInterestRate then
   maxBy FixedInterestRate -> rate




.. _CamelCase: https://en.wikipedia.org/wiki/Camel_case
.. _UTC: https://en.wikipedia.org/wiki/Coordinated_Universal_Time

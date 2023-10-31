using {RiskService} from './risk-service';

annotate RiskService.Risks with {
    title  @title: 'Title';
    prio   @title: 'Priority';
    descr  @title: 'Description';
    miti   @title: 'Mitigations';
    impact @title: 'Impact';
};

annotate RiskService.Mitigations with {
    ID          @(
        UI.Hidden,
        Common: {Text: description}
    );
    description @title: 'Description';
    owner       @title: 'Owner';
    timeline    @title: 'Timeline';
    risks       @title: 'Risks';
};

annotate RiskService.Risks with @(UI: {
    HeaderInfo      : {
        TypeName      : 'Risk',
        TypeNamePlural: 'Risks',
        Title         : {
            $Type: 'UI.DataField',
            Value: title,
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: descr,
        },
    },
    SelectionFields : [prio],
    LineItem        : [
        {Value: title},
        {
            Value                 : miti_ID,
            ![@HTML5.CssDefaults] : {width: '100%'}
        },
        {
            Value      : prio,
            Criticality: criticality,
        },
        {
            Value      : impact,
            Criticality: criticality
        }
    ],
    Facets          : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Main',
        Target: '@UI.FieldGroup#Main',
    }],
    FieldGroup #Main: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {Value: miti_ID, },
            {
                Value      : prio,
                Criticality: criticality
            },
            {
                Value      : impact,
                Criticality: criticality
            }
        ],
    },
}) {}

annotate RiskService.Risks with {
    miti @(Common: {
        Text           : miti.description,
        TextArrangement: #TextOnly,
        ValueList      : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Mitigations',
            Label         : 'Mitigations',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: miti_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'description',
                }
            ],
        },
    })
};
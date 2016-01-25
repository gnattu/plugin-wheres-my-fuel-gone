{React, ReactDOM} = window
{Grid, Col, Row, Alert, Panel} = ReactBootstrap
InlineEdit = require('react-edit-inline').default
path = require 'path-extra'
classnames = require 'classnames'

{MaterialIcon} = require path.join(ROOT, 'views', 'components', 'etc', 'icon')
{translateRuleList} = require path.join(__dirname, 'filter_selector')

BookmarkTile = React.createClass
  getInitialState: ->
    showDetail: false

  onSwitchDetail: ->
    @setState
      showDetail: !@state.showDetail

  render: ->
    fullRecords = @props.fullRecords
    filterJson = @props.filterJson
    filter = translateRuleList filterJson.rules
    if filter.errors
      title = [<i className='fa fa-exclamation-triangle icon-margin-right-5' key=1></i>,
        <span key=2>{__ 'Invalid filter'}</span>]
      body = <ul className='bookmark-ul'>
       {
        for error, i in filter.errors
          <li key=i>{error}</li>
       }
      </ul>
    else
      data = fullRecords.filter filter.func
      ruleTexts = filter.texts || []
      time = filterJson.time
      consumption = sumUpConsumption data
      consumption = resource5to4(consumption[0..4]).concat(consumption[5])
      title = [<InlineEdit
        key='name-text'
        validate={(text) -> (text.length > 0 && text.length < 32)}
        text={filterJson.name}
        paramName='name'
        className='name-editing'
        activeClassName='name-editing-active'
        change={@props.onChangeName}
        />
        <i className='fa fa-pencil-square-o title-hover-show-inline grey-icon icon-margin-left-5'
          key='name-edit-icon'></i> ]
      body = 
        <Row>
          {
            for [num, iconNo] in _.zip(consumption, [1, 2, 3, 4, 6])
              <Col xs=3 key={iconNo}>
                <div className='bookmark-icon-wrapper'>
                  <MaterialIcon materialId={iconNo} />
                </div>
                {num}
              </Col>
          }
          <Col xs=9>
            <div className='bookmark-icon-wrapper'>
              <i className='fa fa-paper-plane-o'></i>
            </div>
            {__ "%s sorties", data.length}
          </Col>
        </Row>
    removeWrapperStyle = if @state.showDetail then '' else 'bookmark-hover-show'
    header = <div style={position: 'relative'}>
        { title }
        <div style={position: 'absolute', top: 0, right: 0} 
          className={removeWrapperStyle}>
          <i className='fa fa-trash-o remove-rule-icon'
            onClick={@props.onRemoveFilter}></i>
        </div>
      </div>
    <div className='col-xs-12 bookmark-width bookmark-wrapper' onClick={@onSwitchDetail}>
      <div ref='mainPanel'>
        <Panel className='bookmark-maxwidth bookmark-panel' header={header}>
          { body }
        </Panel>
      </div>
       {
        if ruleTexts?
          <div className='bookmark-appendix-psuedo'>
            <div className='bookmark-appendix-positioner'>
              <Panel className='bookmark-maxwidth bookmark-appendix'
                collapsible expanded={@state.showDetail}>
                <ul className='bookmark-ul'>
                 {
                  for ruleText in ruleTexts
                    <li>
                      {ruleText}
                    </li>
                 }
                </ul>
              </Panel>
            </div>
          </div>
       }
    </div>

TabBookmarks = React.createClass
  changeName: (time, value) ->
    name = value.name
    @props.onChangeFilterName? time, name

  removeFilter: (time) ->
    @props.onRemoveFilter? time

  render: ->
    fullRecords = @props.fullRecords
    <div className='tabcontents-wrapper'>
     {
      if !@props.filterList || !Object.keys(@props.filterList).length
        <Alert bsStyle="warning" style={maxWidth: 800}>
          <h3>
            {__ "You do not have any filters currently"}
          </h3>
          {__ "Create a filter in the Table tab, and bookmark it to show it here"}
        </Alert>
      else
        <div>
         {
          for time, filterJson of @props.filterList
            <BookmarkTile
              key={"bookmark-#{time}"}
              fullRecords=fullRecords
              filterJson=filterJson
              onRemoveFilter={@removeFilter.bind(this, time)}
              onChangeName={@changeName.bind(this, time)}
              />
              
         }
        </div>
     }
    </div>

module.exports = {TabBookmarks}
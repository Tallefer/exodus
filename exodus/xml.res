        ��  ��                  z(  4   X M L   D E F A U L T S         0 	        <exodus version="0.9">
    <prefs>
        <defaults_xml_cvs_id value="$Id: defaults.xml,v 1.30 2003/12/19 23:18:05 hildjj Exp $"/>

        <!-- AutoAway prefs -->
        <auto_away value="1" control="chkAutoAway"/>
    	<aa_reduce_pri value="1" control="chkAAReducePri"/>
        <auto_xa value="1" control="chkAutoXA"/>
        <auto_disconnect value="0" control="chkAutoDisconnect"/>
        <away_time value="5" control="spnAway"/>
        <xa_time value="30" control="spnXA"/>
        <disconnect_time value="180" control="spnDisconnect"/>
        
        <away_status control="txtAway" state="ro">
            <control name="lblAwayStatus"/>
        </away_status>
        
        <xa_status control="txtXA" state="ro">
            <control name="lblXAStatus"/>
        </xa_status>

        <!-- Roster Options -->                    	
        <roster_show_unsub value="0" control="chkShowUnsubs"/>
        <roster_show_pending value="1" control="chkShowPending"/>
        <roster_hide_block value="0" control="chkHideBlocked"/>
        <roster_pres_errors  value="0" control="chkPresErrors"/>
        <roster_unicode value="true" control="chkRosterUnicode"/>
        <roster_chat value="2" control="cboDblClick">
        	<control name="lblDblClick"/>
    	</roster_chat>

        <inline_status value="0" control="chkInlineStatus"/>
        <inline_color value="$0000FF00" control="cboInlineStatus"/>
        <nested_groups value="1" control="chkNestedGrps"/>
        <group_seperator value="/" control="txtGrpSeperator"/>


        <!-- unfiled -->
        <roster_bg value="$80000005"/>
        <roster_groupcounts value="1"/>
        <roster_messenger value="1"/>
        <roster_offline_group value="0"/>
        <roster_only_online value="0"/>
        <roster_transport_grp value="Transports"/>

        <always_lang value="0"></always_lang>

        <!-- PONL -->
        <auto_update_url value="http://ponl-im/exodus/upgrade/setup.exe" status='ro'>
        </auto_update_url>

        <!-- PONL -->
    	<auto_update_changelog_url value="http://exodus.jabberstudio.org/ChangeLog-RELEASE.txt" status='ro'>
    	</auto_update_changelog_url>
    	
        <auto_updates value="1"></auto_updates>
        <autologin value="0"></autologin>
        <brand_ad ></brand_ad>
        <brand_ad_url ></brand_ad_url>

        <!-- PONL -->
        <brand_caption value="PONL Instant Messaging" status='ro'></brand_caption>
        <brand_help_menu_list status='ro'>
            <s>User Guide</s> <!-- PONL -->
            <s>Privacy Statement</s> <!-- PONL -->
        </brand_help_menu_list>
        <brand_help_url_list status='ro'>
            <s>http://ponl-im/exodus/userguide.htm</s> <!-- PONL -->
            <s>http://ponl-im/exodus/privacy.htm/</s> <!-- PONL -->
        </brand_help_url_list>
        <brand_icon ></brand_icon>
        <brand_profile_conn_type value="0"></brand_profile_conn_type>
        <brand_profile_host></brand_profile_host>
        <brand_profile_http_poll value="1000"></brand_profile_http_poll>
        <brand_profile_http_url ></brand_profile_http_url>
        <brand_profile_num_poll_keys value="256"></brand_profile_num_poll_keys>
        <brand_profile_password ></brand_profile_password>
        <brand_profile_port value="5222"></brand_profile_port>
        <brand_profile_priority value="1"></brand_profile_priority>
        <brand_profile_resource value="Exodus"></brand_profile_resource>
        
        <brand_profile_resource_list>
            <s>Home</s>
            <s>Work</s>
            <s>Exodus</s>
        </brand_profile_resource_list>
        
        <brand_profile_save_password ></brand_profile_save_password>
        <!-- PONL -->
        <brand_profile_server value="ponl-im" status='ro'></brand_profile_server>
        
        <!-- PONL -->
        <brand_profile_server_list status='ro'>
            <s>ponl-im</s>
        </brand_profile_server_list>
        
        <brand_profile_socks_auth value="false"></brand_profile_socks_auth>
        <brand_profile_socks_host ></brand_profile_socks_host>
        <brand_profile_socks_password ></brand_profile_socks_password>
        <brand_profile_socks_port value="1080"></brand_profile_socks_port>
        <brand_profile_socks_type value="0"></brand_profile_socks_type>
        <brand_profile_socks_user ></brand_profile_socks_user>
        <brand_profile_ssl value="false"></brand_profile_ssl>
        <brand_profile_srv value="true"></brand_profile_srv>
        <brand_profile_username ></brand_profile_username>
        <brand_muc value="1"></brand_muc>

        <!-- PONL -->    
        <brand_ft value="0" status='ro'></brand_ft>
        <brand_plugs value="1" status='ro'></brand_plugs>

        <!-- PONL -->    
        <brand_addcontact_gateways value="0" status='ro'/>
        <!-- PONL -->    
        <brand_registration value="0" status='ro'/>
        <!-- PONL -->    
        <brand_browser value="0" status='ro'/>
        <!-- PONL -->    
        <brand_vcard value="0" status='ro'></brand_vcard>
        <browse_view value="0"></browse_view>
        <chat_memory value="60"></chat_memory>
        <client_caps value="1"></client_caps>
        
        <client_caps_uri value="http://exodus.jabberstudio.org/caps">
        </client_caps_uri>
        
        <close_min value="1"></close_min>
        <color_bg value="$ffffff"></color_bg>
        <color_me value="$ff0000"></color_me>
        <color_other value="$0000ff"></color_other>
        <debug value="0"></debug>
        <edge_snap value="15"></edge_snap>
        <emoticons value="1"></emoticons>
        <event_width value="315"></event_width>
        <expanded value="0"></expanded>
        <fade_limit value="100"></fade_limit>
        <font_bold value="0"></font_bold>
        <font_color value="0"></font_color>
        <font_italic value="0"></font_italic>
        <font_name value="Arial"></font_name>
        <font_size value="10"></font_size>
        <font_underline value="0"></font_underline>
        <http_proxy_approach value="0"></http_proxy_approach>
        <http_proxy_auth value="false"></http_proxy_auth>
        <http_proxy_host ></http_proxy_host>
        <http_proxy_password ></http_proxy_password>
        <http_proxy_port value="8080"></http_proxy_port>
        <http_proxy_user ></http_proxy_user>
        <log value="1"></log>
        <notify_active value="1"></notify_active>
        <notify_chatactivity value="4"></notify_chatactivity>
        <notify_invite value="1"></notify_invite>
        <notify_keyword value="1"></notify_keyword>
        <notify_newchat value="1"></notify_newchat>
        <notify_normalmsg value="1"></notify_normalmsg>
        <notify_online value="1"></notify_online>
        <notify_oob value="1"></notify_oob>
        <notify_roomactivity value="1"></notify_roomactivity>
        <notify_s10n value="1"></notify_s10n>
        <notify_sounds value="1"></notify_sounds>
        <notify_flasher value="1"></notify_flasher>
        <pres_tracking value="1"></pres_tracking>
        <presence_message_listen value="1"></presence_message_listen>
        <presence_message_send value="1"></presence_message_send>
        <profile_active value="0"></profile_active>
        <s10n_auto_accept value="0"></s10n_auto_accept>
        <single_instance value="1"></single_instance>
        <snap_on value="1"></snap_on>
        <timestamp value="1"></timestamp>
        <timestamp_format value="t"></timestamp_format>
        <toolbar value="1"></toolbar>
        <toast_duration value="5"></toast_duration>
        <warn_closebusy value="1"></warn_closebusy>
        <wrap_input value="1"></wrap_input>
        <roster_default value="Friends"></roster_default>
        <xfer_port value="5280"></xfer_port>
        <close_hotkey value="Alt + W"></close_hotkey>
    </prefs>

    <!-- default custom presence stuff -->
    <presii>
        <presence name='Available'>
        	<show/>
            <status>Available</status>
            <priority/>
            <hotkey>Ctrl+O</hotkey>
        </presence>
        <presence name='Free for Chat'>
        	<show>chat</show>
            <status>Free for Chat</status>
            <priority/>
            <hotkey/>
        </presence>
    
        <presence name='Away'>
        	<show>away</show>
            <status>Away</status>
            <priority/>
            <hotkey>Ctrl+A</hotkey>
        </presence>
        <presence name='Lunch'>
        	<show>away</show>
            <status>Lunch</status>
            <priority/>
            <hotkey>Ctrl+L</hotkey>
        </presence>
        <presence name='Meeting'>
        	<show>away</show>
            <status>Meeting</status>
            <priority/>
            <hotkey>Ctrl+M</hotkey>
        </presence>
        <presence name='Bank'>
        	<show>away</show>
            <status>Bank</status>
            <priority/>
            <hotkey/>
        </presence>
    
        <presence name='Extended Away'>
        	<show>xa</show>
            <status>Extended Away</status>
            <priority/>
            <hotkey/>
        </presence>
        <presence name='Gone Home'>
        	<show>xa</show>
            <status>Gone Home</status>
            <priority/>
            <hotkey/>
        </presence>
        <presence name='Gone to Work'>
        	<show>xa</show>
            <status>Gone to Work</status>
            <priority/>
            <hotkey/>
        </presence>
        <presence name='Sleeping'>
        	<show>xa</show>
            <status>Sleeping</status>
            <priority/>
            <hotkey/>
        </presence>
    
        <presence name='Busy'>
        	<show>dnd</show>
            <status>Busy</status>
            <priority/>
            <hotkey/>
        </presence>
        <presence name='Working'>
        	<show>dnd</show>
            <status>Working</status>
            <priority/>
            <hotkey/>
        </presence>
        <presence name='Mad'>
        	<show>dnd</show>
            <status>Mad</status>
            <priority/>
            <hotkey/>
        </presence>
    </presii>

</exodus>
  /
  ,   X M L   L A N G S       0 	        <langs>
<om>(Afan) Oromo</om>
<ab>Abkhazian</ab>
<aa>Afar</aa>
<af>Afrikaans</af>
<sq>Albanian</sq>
<am>Amharic</am>
<ar>Arabic</ar>
<hy>Armenian</hy>
<as>Assamese</as>
<ay>Aymara</ay>
<az>Azerbaijani</az>
<ba>Bashkir</ba>
<eu>Basque</eu>
<bn>Bengali</bn>
<dz>Bhutani</dz>
<bh>Bihari</bh>
<bi>Bislama</bi>
<br>Breton</br>
<bg>Bulgarian</bg>
<my>Burmese</my>
<be>Byelorussian</be>
<km>Cambodian</km>
<ca>Catalan</ca>
<zh>Chinese</zh>
<co>Corsican</co>
<hr>Croatian</hr>
<cs>Czech</cs>
<da>Danish</da>
<dk>Danish</dk>
<nl>Dutch</nl>
<en>English</en>
<eo>Esperanto</eo>
<et>Estonian</et>
<fo>Faeroese</fo>
<fj>Fiji</fj>
<fi>Finnish</fi>
<fr>French</fr>
<fy>Frisian</fy>
<gl>Galician</gl>
<ka>Georgian</ka>
<de>German</de>
<el>Greek</el>
<kl>Greenlandic</kl>
<gn>Guarani</gn>
<gu>Gujarati</gu>
<ha>Hausa</ha>
<he>Hebrew </he>
<hi>Hindi</hi>
<hu>Hungarian</hu>
<is>Icelandic</is>
<id>Indonesian </id>
<ia>Interlingua</ia>
<ie>Interlingue</ie>
<ik>Inupiak</ik>
<iu>Inuktitut (Eskimo)</iu>
<ga>Irish</ga>
<it>Italian</it>
<ja>Japanese</ja>
<jw>Javanese</jw>
<kn>Kannada</kn>
<ks>Kashmiri</ks>
<kk>Kazakh</kk>
<rw>Kinyarwanda</rw>
<ky>Kirghiz</ky>
<rn>Kirundi</rn>
<ko>Korean</ko>
<ku>Kurdish</ku>
<lo>Laothian</lo>
<la>Latin</la>
<lv>Latvian, Lettish</lv>
<ln>Lingala</ln>
<lt>Lithuanian</lt>
<mk>Macedonian</mk>
<mg>Malagasy</mg>
<ms>Malay</ms>
<ml>Malayalam</ml>
<mt>Maltese</mt>
<mi>Maori</mi>
<mr>Marathi</mr>
<mo>Moldavian</mo>
<mn>Mongolian</mn>
<na>Nauru</na>
<ne>Nepali</ne>
<no>Norwegian</no>
<oc>Occitan</oc>
<or>Oriya</or>
<ps>Pashto, Pushto</ps>
<fa>Persian</fa>
<pl>Polish</pl>
<pt>Portuguese</pt>
<pa>Punjabi</pa>
<qu>Quechua</qu>
<rm>Rhaeto-Romance</rm>
<ro>Romanian</ro>
<ru>Russian</ru>
<sm>Samoan</sm>
<sg>Sangro</sg>
<sa>Sanskrit</sa>
<gd>Scots Gaelic</gd>
<sr>Serbian</sr>
<sh>Serbo-Croatian</sh>
<st>Sesotho</st>
<tn>Setswana</tn>
<sn>Shona</sn>
<sd>Sindhi</sd>
<si>Singhalese</si>
<ss>Siswati</ss>
<sk>Slovak</sk>
<sl>Slovenian</sl>
<so>Somali</so>
<es>Spanish</es>
<su>Sudanese</su>
<sw>Swahili</sw>
<sv>Swedish</sv>
<tl>Tagalog</tl>
<tg>Tajik</tg>
<ta>Tamil</ta>
<tt>Tatar</tt>
<te>Tegulu</te>
<th>Thai</th>
<bo>Tibetan</bo>
<ti>Tigrinya</ti>
<to>Tonga</to>
<ts>Tsonga</ts>
<tr>Turkish</tr>
<tk>Turkmen</tk>
<tw>Twi</tw>
<ug>Uigur</ug>
<uk>Ukrainian</uk>
<ur>Urdu</ur>
<uz>Uzbek</uz>
<vi>Vietnamese</vi>
<vo>Volapuk</vo>
<cy>Welch</cy>
<wo>Wolof</wo>
<xh>Xhosa</xh>
<yi>Yiddish (former ji)</yi>
<yo>Yoruba</yo>
<za>Zhuang</za>
<zu>Zulu</zu>
</langs> �  4   X M L   C O U N T R I E S       0 	        <countries>
<AD>Andorra, Principality of</AD>
<AE>United Arab Emirates</AE>
<AF>Afghanistan, Islamic State of</AF>
<AG>Antigua and Barbuda</AG>
<AI>Anguilla</AI>
<AL>Albania</AL>
<AM>Armenia</AM>
<AN>Netherlands Antilles</AN>
<AO>Angola</AO>
<AQ>Antarctica</AQ>
<AR>Argentina</AR>
<AS>American Samoa</AS>
<AT>Austria</AT>
<AU>Australia</AU>
<AW>Aruba</AW>
<AZ>Azerbaidjan</AZ>
<BA>Bosnia-Herzegovina</BA>
<BB>Barbados</BB>
<BD>Bangladesh</BD>
<BE>Belgium</BE>
<BF>Burkina Faso</BF>
<BG>Bulgaria</BG>
<BH>Bahrain</BH>
<BI>Burundi</BI>
<BJ>Benin</BJ>
<BM>Bermuda</BM>
<BN>Brunei Darussalam</BN>
<BO>Bolivia</BO>
<BR>Brazil</BR>
<BS>Bahamas</BS>
<BT>Bhutan</BT>
<BV>Bouvet Island</BV>
<BW>Botswana</BW>
<BY>Belarus</BY>
<BZ>Belize</BZ>
<CA>Canada</CA>
<CC>Cocos (Keeling) Islands</CC>
<CF>Central African Republic</CF>
<CD>Congo, The Democratic Republic of the</CD>
<CG>Congo</CG>
<CH>Switzerland</CH>
<CI>Ivory Coast (Cote D'Ivoire)</CI>
<CK>Cook Islands</CK>
<CL>Chile</CL>
<CM>Cameroon</CM>
<CN>China</CN>
<CO>Colombia</CO>
<CR>Costa Rica</CR>
<CS>Former Czechoslovakia</CS>
<CU>Cuba</CU>
<CV>Cape Verde</CV>
<CX>Christmas Island</CX>
<CY>Cyprus</CY>
<CZ>Czech Republic</CZ>
<DE>Germany</DE>
<DJ>Djibouti</DJ>
<DK>Denmark</DK>
<DM>Dominica</DM>
<DO>Dominican Republic</DO>
<DZ>Algeria</DZ>
<EC>Ecuador</EC>
<EDU>Educational</EDU>
<EE>Estonia</EE>
<EG>Egypt</EG>
<EH>Western Sahara</EH>
<ER>Eritrea</ER>
<ES>Spain</ES>
<ET>Ethiopia</ET>
<FI>Finland</FI>
<FJ>Fiji</FJ>
<FK>Falkland Islands</FK>
<FM>Micronesia</FM>
<FO>Faroe Islands</FO>
<FR>France</FR>
<FX>France (European Territory)</FX>
<GA>Gabon</GA>
<GB>Great Britain</GB>
<GD>Grenada</GD>
<GE>Georgia</GE>
<GF>French Guyana</GF>
<GH>Ghana</GH>
<GI>Gibraltar</GI>
<GL>Greenland</GL>
<GM>Gambia</GM>
<GN>Guinea</GN>
<GP>Guadeloupe (French)</GP>
<GQ>Equatorial Guinea</GQ>
<GR>Greece</GR>
<GS>S. Georgia & S. Sandwich Isls.</GS>
<GT>Guatemala</GT>
<GU>Guam (USA)</GU>
<GW>Guinea Bissau</GW>
<GY>Guyana</GY>
<HK>Hong Kong</HK>
<HM>Heard and McDonald Islands</HM>
<HN>Honduras</HN>
<HR>Croatia</HR>
<HT>Haiti</HT>
<HU>Hungary</HU>
<ID>Indonesia</ID>
<IE>Ireland</IE>
<IL>Israel</IL>
<IN>India</IN>
<IO>British Indian Ocean Territory</IO>
<IQ>Iraq</IQ>
<IR>Iran</IR>
<IS>Iceland</IS>
<IT>Italy</IT>
<JM>Jamaica</JM>
<JO>Jordan</JO>
<JP>Japan</JP>
<KE>Kenya</KE>
<KG>Kyrgyz Republic (Kyrgyzstan)</KG>
<KH>Cambodia, Kingdom of</KH>
<KI>Kiribati</KI>
<KM>Comoros</KM>
<KN>Saint Kitts & Nevis Anguilla</KN>
<KP>North Korea</KP>
<KR>South Korea</KR>
<KW>Kuwait</KW>
<KY>Cayman Islands</KY>
<KZ>Kazakhstan</KZ>
<LA>Laos</LA>
<LB>Lebanon</LB>
<LC>Saint Lucia</LC>
<LI>Liechtenstein</LI>
<LK>Sri Lanka</LK>
<LR>Liberia</LR>
<LS>Lesotho</LS>
<LT>Lithuania</LT>
<LU>Luxembourg</LU>
<LV>Latvia</LV>
<LY>Libya</LY>
<MA>Morocco</MA>
<MC>Monaco</MC>
<MD>Moldavia</MD>
<MG>Madagascar</MG>
<MH>Marshall Islands</MH>
<MIL>USA Military</MIL>
<MK>Macedonia</MK>
<ML>Mali</ML>
<MM>Myanmar</MM>
<MN>Mongolia</MN>
<MO>Macau</MO>
<MP>Northern Mariana Islands</MP>
<MQ>Martinique (French)</MQ>
<MR>Mauritania</MR>
<MS>Montserrat</MS>
<MT>Malta</MT>
<MU>Mauritius</MU>
<MV>Maldives</MV>
<MW>Malawi</MW>
<MX>Mexico</MX>
<MY>Malaysia</MY>
<MZ>Mozambique</MZ>
<NA>Namibia</NA>
<NC>New Caledonia (French)</NC>
<NE>Niger</NE>
<NET>Network</NET>
<NF>Norfolk Island</NF>
<NG>Nigeria</NG>
<NI>Nicaragua</NI>
<NL>Netherlands</NL>
<NO>Norway</NO>
<NP>Nepal</NP>
<NR>Nauru</NR>
<NT>Neutral Zone</NT>
<NU>Niue</NU>
<NZ>New Zealand</NZ>
<OM>Oman</OM>
<PA>Panama</PA>
<PE>Peru</PE>
<PF>Polynesia (French)</PF>
<PG>Papua New Guinea</PG>
<PH>Philippines</PH>
<PK>Pakistan</PK>
<PL>Poland</PL>
<PM>Saint Pierre and Miquelon</PM>
<PN>Pitcairn Island</PN>
<PR>Puerto Rico</PR>
<PT>Portugal</PT>
<PW>Palau</PW>
<PY>Paraguay</PY>
<QA>Qatar</QA>
<RE>Reunion (French)</RE>
<RO>Romania</RO>
<RU>Russian Federation</RU>
<RW>Rwanda</RW>
<SA>Saudi Arabia</SA>
<SB>Solomon Islands</SB>
<SC>Seychelles</SC>
<SD>Sudan</SD>
<SE>Sweden</SE>
<SG>Singapore</SG>
<SH>Saint Helena</SH>
<SI>Slovenia</SI>
<SJ>Svalbard and Jan Mayen Islands</SJ>
<SK>Slovak Republic</SK>
<SL>Sierra Leone</SL>
<SM>San Marino</SM>
<SN>Senegal</SN>
<SO>Somalia</SO>
<SR>Suriname</SR>
<ST>Saint Tome (Sao Tome) and Principe</ST>
<SU>Former USSR</SU>
<SV>El Salvador</SV>
<SY>Syria</SY>
<SZ>Swaziland</SZ>
<TC>Turks and Caicos Islands</TC>
<TD>Chad</TD>
<TF>French Southern Territories</TF>
<TG>Togo</TG>
<TH>Thailand</TH>
<TJ>Tadjikistan</TJ>
<TK>Tokelau</TK>
<TM>Turkmenistan</TM>
<TN>Tunisia</TN>
<TO>Tonga</TO>
<TP>East Timor</TP>
<TR>Turkey</TR>
<TT>Trinidad and Tobago</TT>
<TV>Tuvalu</TV>
<TW>Taiwan</TW>
<TZ>Tanzania</TZ>
<UA>Ukraine</UA>
<UG>Uganda</UG>
<UK>United Kingdom</UK>
<UM>USA Minor Outlying Islands</UM>
<US>United States</US>
<UY>Uruguay</UY>
<UZ>Uzbekistan</UZ>
<VA>Holy See (Vatican City State)</VA>
<VC>Saint Vincent & Grenadines</VC>
<VE>Venezuela</VE>
<VG>Virgin Islands (British)</VG>
<VI>Virgin Islands (USA)</VI>
<VN>Vietnam</VN>
<VU>Vanuatu</VU>
<WF>Wallis and Futuna Islands</WF>
<WS>Samoa</WS>
<YE>Yemen</YE>
<YT>Mayotte</YT>
<YU>Yugoslavia</YU>
<ZA>South Africa</ZA>
<ZM>Zambia</ZM>
<ZR>Zaire</ZR>
<ZW>Zimbabwe</ZW>
</countries>   
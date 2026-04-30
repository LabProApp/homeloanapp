/// Dart mirror of MasterEnums.java — every nested enum maps 1-to-1.
///
/// Use [EnumName.value.name] to get the server-side string (e.g. 'SALARIED').

// ── Employment ────────────────────────────────────────────────────────────────

enum EmploymentType {
  salaried,
  selfEmployed,
  publicSector;

  String get value => switch (this) {
        EmploymentType.salaried    => 'SALARIED',
        EmploymentType.selfEmployed => 'SELF_EMPLOYED',
        EmploymentType.publicSector => 'PUBLIC_SECTOR',
      };

  static EmploymentType? fromValue(String? v) => switch (v) {
        'SALARIED'      => EmploymentType.salaried,
        'SELF_EMPLOYED' => EmploymentType.selfEmployed,
        'PUBLIC_SECTOR' => EmploymentType.publicSector,
        _               => null,
      };
}

// ── Loan Type ─────────────────────────────────────────────────────────────────

enum LoanType {
  home,
  lap,
  balanceTransfer;

  String get value => switch (this) {
        LoanType.home            => 'HOME',
        LoanType.lap             => 'LAP',
        LoanType.balanceTransfer => 'BALANCE_TRANSFER',
      };

  static LoanType? fromValue(String? v) => switch (v) {
        'HOME'             => LoanType.home,
        'LAP'              => LoanType.lap,
        'BALANCE_TRANSFER' => LoanType.balanceTransfer,
        _                  => null,
      };
}

// ── Inquiry Type ──────────────────────────────────────────────────────────────

enum InquiryType {
  homeLoan,
  propertyRegistration,
  propertyInquiry,
  rentAgreement,
  lap,
  balanceTransfer,
  buyHome,
  sellHome,
  documentServices,
  loanTransfer,
  homeRental,
  commercial;

  String get value => switch (this) {
        InquiryType.homeLoan             => 'HOME_LOAN',
        InquiryType.propertyRegistration => 'PROPERTY_REGISTRATION',
        InquiryType.propertyInquiry      => 'PROPERTY_INQUIRY',
        InquiryType.rentAgreement        => 'RENT_AGREEMENT',
        InquiryType.lap                  => 'LAP',
        InquiryType.balanceTransfer      => 'BALANCE_TRANSFER',
        InquiryType.buyHome              => 'BUY_HOME',
        InquiryType.sellHome             => 'SELL_HOME',
        InquiryType.documentServices     => 'DOCUMENT_SERVICES',
        InquiryType.loanTransfer         => 'LOAN_TRANSFER',
        InquiryType.homeRental           => 'HOME_RENTAL',
        InquiryType.commercial           => 'COMMERCIAL',
      };

  static InquiryType? fromValue(String? v) => switch (v) {
        'HOME_LOAN'             => InquiryType.homeLoan,
        'PROPERTY_REGISTRATION' => InquiryType.propertyRegistration,
        'PROPERTY_INQUIRY'      => InquiryType.propertyInquiry,
        'RENT_AGREEMENT'        => InquiryType.rentAgreement,
        'LAP'                   => InquiryType.lap,
        'BALANCE_TRANSFER'      => InquiryType.balanceTransfer,
        'BUY_HOME'              => InquiryType.buyHome,
        'SELL_HOME'             => InquiryType.sellHome,
        'DOCUMENT_SERVICES'     => InquiryType.documentServices,
        'LOAN_TRANSFER'         => InquiryType.loanTransfer,
        'HOME_RENTAL'           => InquiryType.homeRental,
        'COMMERCIAL'            => InquiryType.commercial,
        _                       => null,
      };
}

// ── Document Status ───────────────────────────────────────────────────────────

enum DocumentStatus {
  notVerified,
  pending,
  verified,
  reopen,
  cancelled,
  deleted,
  rejected;

  String get value => switch (this) {
        DocumentStatus.notVerified => 'NOT_VERIFIED',
        DocumentStatus.pending     => 'PENDING',
        DocumentStatus.verified    => 'VERIFIED',
        DocumentStatus.reopen      => 'REOPEN',
        DocumentStatus.cancelled   => 'CANCELLED',
        DocumentStatus.deleted     => 'DELETED',
        DocumentStatus.rejected    => 'REJECTED',
      };

  static DocumentStatus? fromValue(String? v) => switch (v) {
        'NOT_VERIFIED' => DocumentStatus.notVerified,
        'PENDING'      => DocumentStatus.pending,
        'VERIFIED'     => DocumentStatus.verified,
        'REOPEN'       => DocumentStatus.reopen,
        'CANCELLED'    => DocumentStatus.cancelled,
        'DELETED'      => DocumentStatus.deleted,
        'REJECTED'     => DocumentStatus.rejected,
        _              => null,
      };
}

// ── Inquiry Status ────────────────────────────────────────────────────────────

enum InquiryStatus {
  newStatus,
  closed,
  inProgress;

  String get value => switch (this) {
        InquiryStatus.newStatus  => 'NEW',
        InquiryStatus.closed     => 'CLOSED',
        InquiryStatus.inProgress => 'INPROGRESS',
      };

  static InquiryStatus? fromValue(String? v) => switch (v) {
        'NEW'        => InquiryStatus.newStatus,
        'CLOSED'     => InquiryStatus.closed,
        'INPROGRESS' => InquiryStatus.inProgress,
        _            => null,
      };
}

// ── Lead Status ───────────────────────────────────────────────────────────────

enum LeadStatus {
  newLead,
  contacted,
  visitPlanned,
  visitDone,
  negotiating,
  closedWon,
  closedLost,
  dropped;

  String get value => switch (this) {
        LeadStatus.newLead      => 'NEW',
        LeadStatus.contacted    => 'CONTACTED',
        LeadStatus.visitPlanned => 'VISIT_PLANNED',
        LeadStatus.visitDone    => 'VISIT_DONE',
        LeadStatus.negotiating  => 'NEGOTIATING',
        LeadStatus.closedWon    => 'CLOSED_WON',
        LeadStatus.closedLost   => 'CLOSED_LOST',
        LeadStatus.dropped      => 'DROPPED',
      };

  static LeadStatus? fromValue(String? v) => switch (v) {
        'NEW'          => LeadStatus.newLead,
        'CONTACTED'    => LeadStatus.contacted,
        'VISIT_PLANNED' => LeadStatus.visitPlanned,
        'VISIT_DONE'   => LeadStatus.visitDone,
        'NEGOTIATING'  => LeadStatus.negotiating,
        'CLOSED_WON'   => LeadStatus.closedWon,
        'CLOSED_LOST'  => LeadStatus.closedLost,
        'DROPPED'      => LeadStatus.dropped,
        _              => null,
      };
}

// ── Package ───────────────────────────────────────────────────────────────────

enum PackageType {
  regular,
  premium,
  elite,
  delux;

  String get value => switch (this) {
        PackageType.regular => 'REGULAR',
        PackageType.premium => 'PREMIUM',
        PackageType.elite   => 'ELITE',
        PackageType.delux   => 'DELUX',
      };

  static PackageType? fromValue(String? v) => switch (v) {
        'REGULAR' => PackageType.regular,
        'PREMIUM' => PackageType.premium,
        'ELITE'   => PackageType.elite,
        'DELUX'   => PackageType.delux,
        _         => null,
      };
}

// ── User Status ───────────────────────────────────────────────────────────────

enum UserStatus {
  active,
  cancelled,
  terminated,
  pending;

  String get value => switch (this) {
        UserStatus.active     => 'ACTIVE',
        UserStatus.cancelled  => 'CANCELLED',
        UserStatus.terminated => 'TERMINATED',
        UserStatus.pending    => 'PENDING',
      };

  static UserStatus? fromValue(String? v) => switch (v) {
        'ACTIVE'     => UserStatus.active,
        'CANCELLED'  => UserStatus.cancelled,
        'TERMINATED' => UserStatus.terminated,
        'PENDING'    => UserStatus.pending,
        _            => null,
      };
}

// ── Property Status ───────────────────────────────────────────────────────────

enum PropertyStatus {
  active,
  cancelled,
  terminated,
  pending;

  String get value => switch (this) {
        PropertyStatus.active     => 'ACTIVE',
        PropertyStatus.cancelled  => 'CANCELLED',
        PropertyStatus.terminated => 'TERMINATED',
        PropertyStatus.pending    => 'PENDING',
      };

  static PropertyStatus? fromValue(String? v) => switch (v) {
        'ACTIVE'     => PropertyStatus.active,
        'CANCELLED'  => PropertyStatus.cancelled,
        'TERMINATED' => PropertyStatus.terminated,
        'PENDING'    => PropertyStatus.pending,
        _            => null,
      };
}

// ── Property Type ─────────────────────────────────────────────────────────────

enum PropertyType {
  plot,
  apartment,
  house,
  builderFloor,
  pg,
  office,
  shop,
  showroom,
  plotShop,
  coWorking,
  agricultural;

  String get value => switch (this) {
        PropertyType.plot         => 'PLOT',
        PropertyType.apartment    => 'APARTMENT',
        PropertyType.house        => 'HOUSE',
        PropertyType.builderFloor => 'BUILDER_FLOOR',
        PropertyType.pg           => 'PG',
        PropertyType.office       => 'OFFICE',
        PropertyType.shop         => 'SHOP',
        PropertyType.showroom     => 'SHOWROOM',
        PropertyType.plotShop     => 'PLOT_SHOP',
        PropertyType.coWorking    => 'CO_WORKING',
        PropertyType.agricultural => 'AGRICULTURAL',
      };

  String get label => switch (this) {
        PropertyType.plot         => 'Plot',
        PropertyType.apartment    => 'Apartment',
        PropertyType.house        => 'House',
        PropertyType.builderFloor => 'Builder Floor',
        PropertyType.pg           => 'PG',
        PropertyType.office       => 'Office',
        PropertyType.shop         => 'Shop',
        PropertyType.showroom     => 'Showroom',
        PropertyType.plotShop     => 'Plot + Shop',
        PropertyType.coWorking    => 'Co-Working',
        PropertyType.agricultural => 'Agricultural',
      };

  static PropertyType? fromValue(String? v) => switch (v) {
        'PLOT'          => PropertyType.plot,
        'APARTMENT'     => PropertyType.apartment,
        'HOUSE'         => PropertyType.house,
        'BUILDER_FLOOR' => PropertyType.builderFloor,
        'PG'            => PropertyType.pg,
        'OFFICE'        => PropertyType.office,
        'SHOP'          => PropertyType.shop,
        'SHOWROOM'      => PropertyType.showroom,
        'PLOT_SHOP'     => PropertyType.plotShop,
        'CO_WORKING'    => PropertyType.coWorking,
        'AGRICULTURAL'  => PropertyType.agricultural,
        _               => null,
      };
}

// ── User Role ─────────────────────────────────────────────────────────────────

enum UserRole {
  admin,
  agent,
  client;

  String get value => switch (this) {
        UserRole.admin  => 'ADMIN',
        UserRole.agent  => 'AGENT',
        UserRole.client => 'CLIENT',
      };

  static UserRole? fromValue(String? v) => switch (v) {
        'ADMIN'  => UserRole.admin,
        'AGENT'  => UserRole.agent,
        'CLIENT' => UserRole.client,
        _        => null,
      };
}

// ── Launch Type ───────────────────────────────────────────────────────────────

enum LaunchType {
  readyToMove,
  newLaunch,
  resale,
  underConstruction;

  String get value => switch (this) {
        LaunchType.readyToMove       => 'READY_TO_MOVE',
        LaunchType.newLaunch         => 'NEW_LAUNCH',
        LaunchType.resale            => 'RESALE',
        LaunchType.underConstruction => 'UNDER_CONSTRUCTION',
      };

  String get label => switch (this) {
        LaunchType.readyToMove       => 'Ready to Move',
        LaunchType.newLaunch         => 'New Launch',
        LaunchType.resale            => 'Resale',
        LaunchType.underConstruction => 'Under Construction',
      };

  static LaunchType? fromValue(String? v) => switch (v) {
        'READY_TO_MOVE'       => LaunchType.readyToMove,
        'NEW_LAUNCH'          => LaunchType.newLaunch,
        'RESALE'              => LaunchType.resale,
        'UNDER_CONSTRUCTION'  => LaunchType.underConstruction,
        _                     => null,
      };
}

// ── Relation Type ─────────────────────────────────────────────────────────────

enum RelationType {
  agent,
  client,
  prospectClient,
  employee;

  String get value => switch (this) {
        RelationType.agent          => 'AGENT',
        RelationType.client         => 'CLIENT',
        RelationType.prospectClient => 'PROSPECT_CLIENT',
        RelationType.employee       => 'EMPLOYEE',
      };

  static RelationType? fromValue(String? v) => switch (v) {
        'AGENT'           => RelationType.agent,
        'CLIENT'          => RelationType.client,
        'PROSPECT_CLIENT' => RelationType.prospectClient,
        'EMPLOYEE'        => RelationType.employee,
        _                 => null,
      };
}

// ── User Relation Status ──────────────────────────────────────────────────────

enum UserRelationStatus {
  active,
  closed,
  rejected;

  String get value => switch (this) {
        UserRelationStatus.active   => 'ACTIVE',
        UserRelationStatus.closed   => 'CLOSED',
        UserRelationStatus.rejected => 'REJECTED',
      };

  static UserRelationStatus? fromValue(String? v) => switch (v) {
        'ACTIVE'   => UserRelationStatus.active,
        'CLOSED'   => UserRelationStatus.closed,
        'REJECTED' => UserRelationStatus.rejected,
        _          => null,
      };
}

// ── User Inquiry Status ───────────────────────────────────────────────────────

enum UserInquiryStatus {
  active,
  closed,
  rejected;

  String get value => switch (this) {
        UserInquiryStatus.active   => 'ACTIVE',
        UserInquiryStatus.closed   => 'CLOSED',
        UserInquiryStatus.rejected => 'REJECTED',
      };

  static UserInquiryStatus? fromValue(String? v) => switch (v) {
        'ACTIVE'   => UserInquiryStatus.active,
        'CLOSED'   => UserInquiryStatus.closed,
        'REJECTED' => UserInquiryStatus.rejected,
        _          => null,
      };
}

// ── Document Legal Service Provider Status ────────────────────────────────────

enum ProviderStatus {
  active,
  cancelled,
  terminated,
  pending;

  String get value => switch (this) {
        ProviderStatus.active     => 'ACTIVE',
        ProviderStatus.cancelled  => 'CANCELLED',
        ProviderStatus.terminated => 'TERMINATED',
        ProviderStatus.pending    => 'PENDING',
      };

  static ProviderStatus? fromValue(String? v) => switch (v) {
        'ACTIVE'     => ProviderStatus.active,
        'CANCELLED'  => ProviderStatus.cancelled,
        'TERMINATED' => ProviderStatus.terminated,
        'PENDING'    => ProviderStatus.pending,
        _            => null,
      };
}
